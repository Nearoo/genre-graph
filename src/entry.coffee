

#import { Tree } from './coffee/tree.coffee'
import * as $ from 'jquery'
import * as querystring from 'query-string'
import { Spotify } from './coffee/spotify.coffee'

spotify = new Spotify location.hash

if spotify.logged_in
    console.log 'Logged in'
    ###
    # Query example
    spotify.query 'recommendations/available-genre-seeds', {},
        (data) => console.log data,
        (err) => console.error err,
        (done) => console.log "Done"
    ###