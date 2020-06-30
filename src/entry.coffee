

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


# Build graph, make resize automatically
dom = $ '#graph-container'
canv = document.getElementById 'graph'
tree = new Tree dom, canv

tree.animate()
tree.on 'node-clicked', (node, event) =>
    if logged_in()
        genre_normed = node.genre.toLowerCase().replace(' ', '-')
        console.log "Showing " + genre_normed
        page.showGenre genre_normed
    else
        console.log "Would show " + node.genre

exports =
    page: page
    tree: tree
    graph: tree.graph
    spotify: page?.spotify
window.entry = exports