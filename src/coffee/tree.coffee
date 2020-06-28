import ForceGraph3D from '3d-force-graph'
import * as three from 'three'
import SpriteText from 'three-spritetext'

class Tree
    constructor: (@graphDomElement, @graphCanvasElement) ->
        @graph = ForceGraph3D {
            rendererConfig:
                canvas: @graphCanvasElement
        }

        @graph(@graphDomElement)
            .nodeLabel 'label'
            .jsonUrl 'json/genre_graph.json'
            .nodeThreeObject (node) =>
                # Collision sphere
                colGeo = new three.SphereGeometry 10
                colMat = new three.MeshBasicMaterial { depthWrite: false, transparent: true, opacity: 0}

                colObj = new three.Mesh colGeo, colMat

                # Label
                sprite = new SpriteText ( node.genre ? '🎷' )
                sprite.textHeight = 8
                colObj.add sprite

                return colObj
        
        @graphData =
            nodes: [
                {
                    id: 0
                    isRoot: true
                }
            ]
            links: []
        @pushUpdates()
        @rootId = 0

        @graph.backgroundColor '#121212' 
    
    addChild: (toId, nodeData={}) =>
            newId = @graphData.nodes.length
            newNode = Object.assign {}, {id: newId, isRoot: false}, nodeData
            @graphData.nodes.push newNode
            @graphData.links.push {
                source: toId,
                target: newId
            }
            @

    setRoot: (newRootId) =>
        linksToSwap = []
        cursor = newRootId
        while cursor != @rootId
            nextLink = @graphData.links.find (link) => link.target == cursor
            linksToSwap.push nextLink
            cursor = nextLink.source
        
        swapLink = (link) =>
            tmp = link.source
            link.source = link.target
            link.target = tmp
        
        swapLink link for link in linksToSwap

        @getNodeData @rootId
            .isRoot = false
        @getNodeData newRootId
            .isRoot = true
        
        @rootId = newRootId

        console.log "Set new Root: ", @rootId
        @
        
    getNodeData: (nodeId) =>
        @graphData.nodes.find (node) => node.id == nodeId

    getNodeGraphData: (nodeId) =>
        @graph.graphData().find (node) => node.id == nodeId
        
    
    pushUpdates: () =>
        dataCopy = JSON.parse JSON.stringify @graphData
        @graph.graphData dataCopy
    
    setRenderSize: (w, h) => 
        @graph.camera().aspect = w / h
        @graph.camera().updateProjectionMatrix()

        @graph.renderer().setSize w, h

export { Tree }
    