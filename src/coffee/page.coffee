###
Provides bindings to interact with DOM
###

import * as EventEmitter from 'events'
import * as $ from 'jquery'
import * as pug from 'pug'
class Page extends EventEmitter
    constructor: ->
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
    
    setPlayButtonState: (state) =>
        switch state
            when 'play' then @gmap.playButton.html pug.render 'i.ion.ion-play'
            when 'pause' then @gmap.playButton.html pug.render 'i.ion.ion-pause'

    clearNavbar: () =>
        @gmap.artists.remove()
        @gmap.playlists.remove()
        @gmap.songs.remove()
    
    addSong: (imgSrc, title, artist) =>
        @gmap.songContainer.append @templates.song {
            imgSrc: imgSrc
            title: title
            artist: artist
        }
    
    addArtist: (imgSrc,name) =>
        @gmap.artistContainer.append @templates.artist {
            imgSrc: imgSrc
            name: name
        }
    
    addPlaylist: (imgSrc, title, author) =>
        @gmap.playlistContainer.append @templates.playlist {
            imgSrc: imgSrc
            title: title
            author: author
        }

export { Page }