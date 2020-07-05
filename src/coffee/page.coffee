###
Provides bindings to interact with DOM
###

import * as EventEmitter from 'events'
import * as $ from 'jquery'
import * as pug from 'pug'
import { spotify } from './spotify.coffee'
import { Graph } from './tree.coffee'

class Page extends EventEmitter
    constructor: ->
        super()

        @gmap =
            playButton: $ '#play-button'
            prevButton: $ '#prev-button'
            nextButton: $ '#next-button'

            songs: $ '#songs'
            artists: $ '#artists'
            playlists: $ '#playlists'

            songContainer: $ '#songs'
            playlistContainer: $ '#playlists'
            artistContainer: $ '#artists'

            currentAlbumImg: $ '#currentPlayingAlbumImg'
            currentAlbumTitle: $ '#currentPlayingAlbumTitle'
            currentTrackName: $ '#currentPlayingTrackTitle'
            currentArtistName: $ '#currentPlayingArtistName'

            timePlayed: $ '#time-left'
            timeRemaining: $ '#time-right'
            progressBar: $ '#progress-bar-progress'

            graphContainer: $ '#graph-container'
        
        @templates =
            song: pug.compile (require 'raw-loader!../pug/index/components/song.pug' ).default
            playlist: pug.compile (require 'raw-loader!../pug/index/components/playlist.pug').default
            artist: pug.compile (require 'raw-loader!../pug/index/components/artist.pug').default
        
        @state = {}

        @gmap.playButton.on 'click', () => @emit 'start-playback'
        @gmap.prevButton.on 'click', () => @emit 'prev-song'
        @gmap.nextButton.on 'click', () => @emit 'next-song'

        @spotify = spotify
        @graph = new Graph @gmap.graphContainer, 'json/genre_graph.json'
        @player = undefined # Initialized later automatically

        @on 'start-playback', =>
            @player?.togglePlay()
        
        @on 'next-song', =>
            @player.nextTrack()
        
        @on 'prev-song', =>
            @player.previousTrack()

        @spotify.on 'player-ready', =>
            @player = @spotify.player

        @spotify.on 'player-state-changed', @syncGuiWithPlayerState

        @graph.on 'node-clicked', (node, ev) =>
            @showGenre node.genre.toLowerCase()
        
        $( document ).on 'click', '.artist, .song, .playlist', (event) =>
            target = $ event.currentTarget
            @spotify.playURI target.attr 'spotify-uri'

        
        setInterval @updatePlaybackBarProgress, 1000
    
    run: =>
        @graph.loop()

    syncGuiWithPlayerState: (state) =>
        track = state.track_window.current_track
        album = track.album

        @gmap.currentAlbumImg.attr 'src', album.images[0].url
        @gmap.currentAlbumTitle.html album.name
        @gmap.currentTrackName.html track.name
        @gmap.currentArtistName.html (artist.name for artist in track.artists).join ', '

        @state.playerPaused = state.paused
        if state.paused
            @setPlayButtonState 'pausing'
        else
            @setPlayButtonState 'playing'
        
        if @state.currentTrackId isnt track.id
            @state.currentTrackId = track.id
            @spotify.getTrackInfo track.id, (tInfo) =>
                @state.currentTrackInfo = tInfo

        @state.playerInitialSeekPos = state.position
        @state.playerInitialSeekPosTimestamp = (new Date).getTime()
    
    updatePlaybackBarProgress: =>
        return unless @state.currentTrackInfo?

        msElapsed = @state.playerInitialSeekPos
        msTotal = @state.currentTrackInfo.duration_ms
        thenStamp = @state.playerInitialSeekPosTimestamp
        nowStamp = (new Date).getTime()

        if not @state.playerPaused 
            msElapsed += (nowStamp - thenStamp)
        
        @state.playerInitialSeekPos = msElapsed
        @state.playerInitialSeekPosTimestamp = nowStamp
        msRemaining = msTotal - msElapsed
        
        elapsed_str = @msToMinuteSecondString msElapsed
        remaining_str = @msToMinuteSecondString msRemaining
        elapsed_pct = msElapsed / msTotal * 100

        @gmap.timePlayed.html elapsed_str
        @gmap.timeRemaining.html remaining_str
        @gmap.progressBar.css 'width', elapsed_pct + '%'
        

    msToMinuteSecondString: (ms) =>
        totalSeconds = ms / 1000

        seconds = String Math.floor totalSeconds % 60
                .padStart 2, '0'
        minutes = Math.floor totalSeconds / 60
        minutes + ':' + seconds
    
    setPlayButtonState: (state) =>
        switch state
            when 'playing' then @gmap.playButton.html pug.render 'i.ion.ion-pause'
            when 'pausing' then @gmap.playButton.html pug.render 'i.ion.ion-play'

    clearNavbar: () =>
        @gmap.artists.html ''
        @gmap.playlists.html ''
        @gmap.songs.html ''

    addArtistFromSpotify: (artist) =>
        @addArtistElement artist.images[0]?.url,
                        artist.name,
                        artist.uri
    
    addTrackFromSpotify: (track) =>
        @addTrackElement track?.album.images[0]?.url,
                        track.name,
                        track.artists[0].name,
                        track.uri
    
    addPlaylistFromSpotify: (playlist) =>
        @addPlaylistElement playlist.images[0]?.url,
                        playlist.name,
                        playlist.owner.display_name,
                        playlist.uri
                        
    addTrackElement: (imgSrc, title, artist, uri) =>
        @gmap.songContainer.append @templates.song {
            imgSrc: imgSrc
            title: title
            artist: artist,
            uri: uri
        }
    
    addPlaylistElement: (imgSrc, title, author, uri) =>
        @gmap.playlistContainer.append @templates.playlist {
            imgSrc: imgSrc
            title: title
            author: author,
            uri: uri
        }
    
    addArtistElement: (imgSrc, name, uri) =>
        @gmap.artistContainer.append @templates.artist {
            imgSrc: imgSrc
            name: name
            uri: uri
        }
    
    showGenre: (genre) =>
        @clearNavbar()
        @spotify.search genre, ['album', 'artist', 'playlist', 'track'], {limit: 10}, (data) =>
            @addArtistFromSpotify artist for artist in data.artists.items
            @addTrackFromSpotify track for track in data.tracks.items
            @addPlaylistFromSpotify playlist for playlist in data.playlists.items

export { Page }