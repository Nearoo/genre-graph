
express = require('express');
request = require('request')
cors = require('cors')
querystring = require('querystring')
cookieParser = require('cookie-parser')

{ client_id, client_secret } = require('./spotify.credentials')
client_creds_b64 = Buffer.from(client_id + ":" + client_secret).toString 'base64'
redirect_uri = 'http://localhost:3000/callback'
state_cookie_key = 'spotify_auth_state'

auth_scopes = ["streaming",
                "user-modify-playback-state",
                "user-read-playback-state",
                "user-read-currently-playing",
                "user-read-email",
                "user-read-private"].join ' '
genRandomStr = (length) =>
    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    (
        for each in [1..length]
            chars.charAt Math.floor (Math.random() * chars.length) 
    ).join ''



router = express.Router()
router.get '/login', (req, res, next) =>
    state = genRandomStr 16
    res.cookie state_cookie_key, state
    res.redirect 'https://accounts.spotify.com/authorize?' +
        querystring.stringify {
            response_type: 'code',
            client_id: client_id,
            scope: auth_scopes,
            redirect_uri: redirect_uri,
            state: state
        }


router.get '/callback', (req, res, next) =>
    code = req.query.code
    state = req.query.state
    storedState = req.cookies?[state_cookie_key]
    if not state? or state isnt storedState
        console.log "State mismatch. Got: \n#{state}\nbut am in:\n#{storedState}"
        res.redirect '/' +
            querystring.stringify error: 'state_mismatch'
    else
        res.clearCookie state_cookie_key
        authOptions =
            url: 'https://accounts.spotify.com/api/token'
            form:
                code: code,
                redirect_uri: redirect_uri
                grant_type: 'authorization_code'
            headers:
                'Authorization': 'Basic ' + client_creds_b64
            json: true

        request.post authOptions, (error, response, body) =>
            if not error and response.statusCode is 200
                access_token = body.access_token
                refresh_token = body.refresh_token
            
                options =
                    url: 'https://api.spotify.com/v1/me'
                    headers:
                        'Authorization': 'Bearer ' + access_token
                    json: true
                
                request.get options, (error, response, body) =>
                    console.log "Spotify: User #{body.display_name} logged in"
                
                res.redirect '/graph#' + querystring.stringify {
                    access_token: access_token
                    refresh_token: refresh_token
                }
            else
                res.redirect '/#' + querystring.stringify {
                    error: 'invalid_token'
                }

router.get '/refresh_token', (req, res, next) =>
    refresh_token = req.query.refresh_token
    authOptions = 
        url: 'https://accounts.spotify.com/api/token'
        headers:
            'Authorization': 'Basic ' + client_creds_b64
        form:
            grant_type: 'refresh_token'
            refresh_token: refresh_token
        json: true
    
    request.post authOptions, (error, response, body) =>
        if not error and response.statusCode is 200
            access_token = body.access_token
            res.send 'access_token': access_token

module.exports = router