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
        
        @state = {}

        @gmap.playButton.on 'click', () => @emit 'start-playback'
        @gmap.prevButton.on 'click', () => @emit 'next-song'
        @gmap.nextButton.on 'click', () => @emit 'prev-song'
    
    setPlayButtonState: (state) =>
        switch state
            when 'play' then @gmap.playButton.html pug.render 'i.ion.ion-play'
            when 'pause' then @gmap.playButton.html pug.render 'i.ion.ion-pause'


export { Page }