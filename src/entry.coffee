

import { Tree } from './coffee/tree.coffee'
import * as $ from 'jquery'
import * as querystring from 'query-string'

import { Page } from './coffee/page.coffee'

{ access_token, refresh_token } = querystring.parse location.hash

logged_in = =>
    access_token? and refresh_token?


if logged_in()
    console.log 'Logged in'
    page = new Page access_token, refresh_token
    page.showGenre 'pop'
    ### To-Do: smh not workng...
    page.spotify.on 'player-ready', () =>
        page.spotify.playURI 'spotify:track:6rqhFgbbKwnb9MLmUQDhG6'
    ###


# Build graph, make resize automatically
dom = document.getElementById 'graph-container'
canv = document.getElementById 'graph'
tree = new Tree dom, canv

window.addEventListener 'resize', () =>
    gc = $('#graph-container')
    tree.setRenderSize gc.width(), gc.height()
