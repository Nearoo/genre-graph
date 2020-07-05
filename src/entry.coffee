


import * as $ from 'jquery'
import * as querystring from 'query-string'

import { Page } from './coffee/page.coffee'


page = new Page

if not page.spotify.logged_in
    window.location.href = "/land"
page.run()