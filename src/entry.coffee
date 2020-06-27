

#import { Tree } from './coffee/tree.coffee'
import * as $ from 'jquery'
import * as querystring from 'query-string'

{ 
    access_token
    refresh_token
} = querystring.parse location.hash

if access_token? and refresh_token?
    console.log 'Logged in.'

