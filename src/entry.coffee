


import * as $ from 'jquery'
import * as querystring from 'query-string'

import { Page } from './coffee/page.coffee'


page = new Page

if not page.spotify.logged_in
    window.location.href = "/land"

# Ugly workaround to interface flickering
page.graph.on 'node-clicked', =>
    setTimeout (=>
        page.graph.updateSize()
    ), 500
page.run()