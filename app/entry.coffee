
import ForceGraph3D from '3d-force-graph'
import { Tree } from './tree.coffee'

tree = new Tree document.getElementById 'graph'

tree.addChild 0
    .addChild 0
    .addChild 0
    .addChild 1
    .addChild 2
    .addChild 3
    .pushUpdates()
