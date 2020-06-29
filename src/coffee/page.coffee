###
Provides bindings to interact with DOM
###

import * as EventEmitter from 'events'
import * as $ from 'jquery'
import * as pug from 'pug'
import { SpotifyAPI } from './spotify.coffee'

class Page extends EventEmitter
    constructor: (@access_token, @refresh_token)->
        super()

        @gmap =
            playButton: $ '#play-button'
            prevButton: $ '#prev-button'
            nextButton: $ '#next-button'

            songs: $ '.song'
            artists: $ '.artist'
            playlists: $ '.playlist'

            songContainer: $ '#songs'
            playlistContainer: $ '#playlists'
            artistContainer: $ '#artists'
        
        @templates =
            song: pug.compile (require 'raw-loader!../pug/index/components/song.pug' ).default
            playlist: pug.compile (require 'raw-loader!../pug/index/components/playlist.pug').default
            artist: pug.compile (require 'raw-loader!../pug/index/components/artist.pug').default
        
        @state = {}

        @gmap.playButton.on 'click', () => @emit 'start-playback'
        @gmap.prevButton.on 'click', () => @emit 'next-song'
        @gmap.nextButton.on 'click', () => @emit 'prev-song'

        @spotify = new SpotifyAPI @access_token, @refresh_token
        @player = @spotify.player
    
        @on 'start-playback', =>
            @player.togglePlay().then =>
                @syncPlayButtonWithPlayer()
        
        @on 'next-song', =>
            @player.nextTrack()
        
        @on 'prev-song', =>
            @pplayer.prevTrack()
    
    syncPlayButtonWithPlayer: () =>
        @player.getCurrentState().then (state) =>
            if state.paused
                @setPlayButtonState 'pause'
            else
                @setPlayButtonState 'play'
    
    playSong: (uri) =>
        
    
    setPlayButtonState: (state) =>
        switch state
            when 'play' then @gmap.playButton.html pug.render 'i.ion.ion-play'
            when 'pause' then @gmap.playButton.html pug.render 'i.ion.ion-pause'

    clearNavbar: () =>
        @gmap.artists.remove()
        @gmap.playlists.remove()
        @gmap.songs.remove()
    
    addSongElement: (imgSrc, title, artist) =>
        @gmap.songContainer.append @templates.song {
            imgSrc: imgSrc
            title: title
            artist: artist
        }
    
    addArtistElement: (imgSrc,name,artistId) =>
        @gmap.artistContainer.append @templates.artist {
            imgSrc: imgSrc
            name: name
            id: artistId
        }
    
    addArtistsById: (artistIds) =>
        @spotify.getArtists artistIds, (data) =>
            @addArtistByObject artist for artist in data.artists

    addArtistByObject: (artist) =>
        imgUrl = artist.images[2].url
        @addArtistElement imgUrl, artist.name, artist.id
    
    addPlaylistElement: (imgSrc, title, author) =>
        @gmap.playlistContainer.append @templates.playlist {
            imgSrc: imgSrc
            title: title
            author: author
        }
    
    showGenre: (genre) =>
        # Requests more info by spotify, then adds them
        @spotify.genreRecommendations genre,
        (data) =>
            for track in data.tracks
                do (track) =>
                    @addArtistsById (artist.id for artist in track.artists)
        , (error) =>
            console.error error

export { Page }