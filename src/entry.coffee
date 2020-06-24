

import { Tree } from './coffee/tree.coffee'
import * as $ from 'jquery'

# Canvas for graph
canv = document.getElementById 'graph'
div = document.getElementById 'graph-container'
###
t = new Tree div, canv


t.addChild 0
    .addChild 0
    .addChild 0
    .addChild 0
    .addChild 1
    .addChild 2
    .addChild 3
    .addChild 4
    .pushUpdates()
###