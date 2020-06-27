import * as $ from 'jquery'
import * as querystring from 'query-string'

# Create getter / setter support for coffee-script
Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}
Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}

class Spotify
    constructor: (location_hash) ->
        { @access_token, @refresh_token } = querystring.parse location_hash
        
        @apiBaseUrl = 'https://api.spotify.com/v1/'
        @authHeaders = 
            Authorization: 'Bearer ' + @access_token
    
    @getter 'logged_in', ->
        @access_token? and @refresh_token?
    
    query: (relativeURL, options={}, done = ->, fail= ->, always= ->) =>
        relativeURL.slice(1) if relativeURL.startsWith('/')
        $.ajax {
            dataType: 'json'
            url: @apiBaseUrl + relativeURL
            headers: @authHeaders
            options: options
            }
            .done done
            .fail fail
            .always always

export { Spotify }
