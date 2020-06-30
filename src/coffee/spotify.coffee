import * as $ from 'jquery'
import * as querystring from 'query-string'
import * as EventEmitter from 'events'


# Circumvent spotify's awkward way to initialize its sdk, allow for later initialiization of player
class SpotifyInitDelayed extends EventEmitter
  constructor: ->
    super()
    @inited = false
    @callbacks = []
    window.onSpotifyWebPlaybackSDKReady = =>
      console.log "Spotify Web Playback SDK initialized."
      @inited = true
      @callAll()

  
  addCallback: (callback) =>
    @callbacks.push callback
    @callAll()
  
  callAll: =>
    if @inited
      while @callbacks.length > 0
        cb = @callbacks.pop()
        cb?()
  
spotifyInitDelayed = new SpotifyInitDelayed

# Create getter / setter support for coffee-script
Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}
Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}


class SpotifyAPI extends EventEmitter
    constructor: (@access_token, @refresh_token) ->
        super()
        
        @apiBaseUrl = 'https://api.spotify.com/v1/'
        @authHeaders = 
            Authorization: 'Bearer ' + @access_token
        
        initPlayer = =>
          console.log 'Spotify webplayer initialized.'
          @player = new Spotify.Player {
            name: 'Genre Graph 🎷'
            getOAuthToken: (cb) => cb(@access_token)
          }
          @player.on 'ready', ({device_id}) =>
            @player_id = device_id
            console.log "Spotify Webplayer initialized."
            @emit 'player-ready'
          
          @player.connect()

        spotifyInitDelayed.addCallback initPlayer
        
    
    @getter 'logged_in', ->
        @access_token? and @refresh_token?
    
    query: (relativeURL, options={}, done = ->, fail= ->, always= ->) =>
        relativeURL.slice(1) if relativeURL.startsWith('/')
        $.ajax {
            dataType: 'json'
            url: @apiBaseUrl + relativeURL + '?' + querystring.stringify options
            headers: @authHeaders
            }
            .done done
            .fail fail
            .always always
    
    getArtists: (artistIds, done= ->, fail= ->) =>
      @query 'artists', {ids: artistIds}, done, fail
    

    genreRecommendations: (genre, done= ->, fail= ->) =>
      @query 'recommendations', {seed_genres: genre}, done, fail
    

    playURI: (uri) =>
      console.log "Playing with player " + @player_id
      $.ajax {
        method: 'PUT',
        contentType: 'application/json'
        headers: @authHeaders,
        body: JSON.stringify { uris: ["spotify:track:462HFjkL2Wnm9zYy8df06Q"] }
        url: 'https://api.spotify.com/v1/me/player/play?' + querystring.stringify {device_id: @player_id}
      }
        .fail (error) => console.log error.responseText


export { SpotifyAPI }
