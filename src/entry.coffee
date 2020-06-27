

#import { Tree } from './coffee/tree.coffee'
import * as $ from 'jquery'
import * as querystring from 'query-string'
import { Spotify } from './coffee/spotify.coffee'

import { Page } from './coffee/page.coffee'

spotify = new Spotify location.hash
page = new Page

page.on 'start-playback', () =>
    if page.state.playing
        page.state.playing = false
        page.setPlayButtonState 'play'
        console.log "Pressed pause"
    else
        page.state.playing = true
        page.setPlayButtonState 'pause'
        console.log "Pressed play"

if spotify.logged_in
    console.log 'Logged in'
    ###
    # Query example
    spotify.query 'recommendations/available-genre-seeds', {},
        (data) => console.log data,
        (err) => console.error err,
        (done) => console.log "Done"
    ###