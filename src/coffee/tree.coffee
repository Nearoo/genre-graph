import ForceGraph3D from '3d-force-graph'

class Tree
    constructor: (@graphDomElement, @graphCanvasElement) ->
        @graph = ForceGraph3D {
            rendererConfig:
                canvas: @graphCanvasElement
        }

        @graph(@graphDomElement)
            .dagMode 'radialout'
            .nodeAutoColorBy 'isRoot'
            .nodeLabel 'id'
            .linkDirectionalArrowLength 3.5
            .linkDirectionalArrowRelPos 1
        
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

export { Tree }
    