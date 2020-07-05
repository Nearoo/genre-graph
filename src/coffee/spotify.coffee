import * as $ from 'jquery'
import * as querystring from 'query-string'
import * as EventEmitter from 'events'

# Create getter / setter support for coffee-script
Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}
Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}


class SpotifyAPI extends EventEmitter
    constructor: ->
        super()
        { @access_token, @refresh_token } = querystring.parse location.hash
        
        @apiBaseUrl = 'https://api.spotify.com/v1/'
        @authHeaders = 
            Authorization: 'Bearer ' + @access_token
        
        window.onSpotifyWebPlaybackSDKReady = =>
          if @logged_in
            @player = new Spotify.Player {
              name: 'Genre Graph 🎷'
              getOAuthToken: (cb) => cb(@access_token)
            }
            @player.on 'ready', (data) =>
              @player_id = data.device_id
              console.log "Player ready."
              @emit 'player-ready'
            
            @player.on 'not_ready', (data) =>
              @emit 'player-not-ready'
              console.error "Player not ready. ", data
            
            @player.on 'player_state_changed', (state) =>
              @emit 'player-state-changed', state

            @player.connect()
          else
            console.log 'User is not logged in, player initialized.'
    
    @getter 'logged_in', ->
        @access_token? and @refresh_token?
    
    simpleQuery: (url, done=->, fail=->) =>
      $.ajax {
        dataType: 'json',
        url: url,
        headers: @authHeaders
      }
        .done done
        .fail fail
    
    query: (relativeURL,
            options={},
            done = console.log,
            fail= console.error,
            always= ->) =>
        relativeURL.slice(1) if relativeURL.startsWith('/')
        qMark = if Object.keys(options).length > 0 then '?' else ''
        $.ajax {
            dataType: 'json'
            url: @apiBaseUrl + relativeURL + qMark + querystring.stringify options
            headers: @authHeaders
            }
            .done done
            .fail fail
            .always always
            
    put: (relativeURL,
          queryOptions={},
          bodyOptions={},
          done = console.log,
          fail= console.error,
          always= ->) =>
        relativeURL.slice(1) if relativeURL.startsWith('/')
        queryParams = querystring.stringify queryOptions

        $.ajax {
            type: 'PUT'
            dataType: 'json'
            data: JSON.stringify bodyOptions
            contentType: 'application/json'
            url: @apiBaseUrl + relativeURL + (if queryParams.length > 0 then '?' else '') + queryParams
            headers: @authHeaders
            }
            .done done
            .fail fail
            .always always
    
    search: (q,
      types=['album', 'artist', 'playlist','track'],
      moreOptions={},
      done, fail) =>
      type = types.join ','
      @query 'search', {
        q: q,
        type: type
        ...moreOptions
      }, done, fail

    getArtists: (artistIds, done= ->, fail= ->) =>
      @query 'artists', {ids: artistIds}, done, fail

    genreRecommendations: (genre, done= ->, fail= ->) =>
      @query 'recommendations', {seed_genres: genre}, done, fail
    
    getTrackInfo: (trackId, done=->, fail=->) =>
      @query 'tracks/' + trackId, {}, done, fail
    
    getArtistTracks: (artistId, done=->, fail=->) =>
      @query 'artists/' + artistId + '/top-tracks', {market: 'from_token'}, done
    
    getPlaylistTracks: (playlistId, done=->, fail=->) =>
      @query 'playlists/' + playlistId, {}, done, fail
    
    playArtistId: (artistId) =>
      @getArtistTracks artistId, (tracks) =>
        uris = (track.uri for track in tracks.tracks)
        @_playURIs uris
    
    playPlaylistId: (playlistId) =>
      @getPlaylistTracks playlistId, (playlists) =>
        uris = (item.track.uri for item in playlists.tracks.items)
        @_playURIs uris

    playURI: (uri) =>
      [_, uriType, id] = uri.split ':'
      switch uriType
        when 'track' then @_playURIs [uri]
        when 'playlist' then @playPlaylistId id
        when 'artist' then @playArtistId id
        when 'album' then throw new Errro 'playback of album uris not supported'
      
    
    _playURIs: (uris) =>
      @put 'me/player/play', {device_id: @player_id}, {
        uris: uris
      }, => # Suppress log of response
    
    playSongURI: (uri) =>
      @playURI uri

spotify = new SpotifyAPI

export { spotify }
