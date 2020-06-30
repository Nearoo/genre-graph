import ThreeForceGraph from 'three-forcegraph'
import * as three from 'three'
import SpriteText from 'three-spritetext'
import OrbitControls from 'three-orbitcontrols'
import * as EventEmitter from 'events'

class Tree extends EventEmitter
    constructor: (@graphDomElement, @graphCanvasElement) ->
        super()
        @scene = new three.Scene
        @camera = new three.PerspectiveCamera 75, 1/1, 0.1, 1000
        @camera.position.z = 50
        @renderer = new three.WebGLRenderer { canvas: @graphCanvasElement }
        window.addEventListener 'resize', =>
            @setRenderSize @graphDomElement.width(), @graphDomElement.height()
        window.dispatchEvent new Event 'resize'

        @controls = new OrbitControls @camera, @renderer.domElement
        @controls.panSpeed = 4

        @graph = new ThreeForceGraph()
            .jsonUrl 'json/genre_graph.json'
            .nodeThreeObject (node) =>
                # Collision sphere
                colGeo = new three.SphereGeometry 20, 23, 23
                #colMat = new three.MeshBasicMaterial { depthWrite: false, transparent: true, opacity: 0.2}
                colMat = new three.MeshLambertMaterial { color: 0xfffffff, depthWrite: false, transparent: true, opacity: 0.2}
                colObj = new three.Mesh colGeo, colMat

                # Label
                sprite = new SpriteText ( node.genre ? '🎷' )
                sprite.textHeight = 16
                colObj.add sprite

                colObj
        @graph.d3Force 'link'
                .distance (node) => 400
        
        @scene.add @graph

        @light = new three.HemisphereLight 0xffffff, 0x0, 1
        @scene.add @light

        @clock = new three.Clock

        window.addEventListener 'click', (ev) =>
            { top, left } = @graphDomElement.position()
            [ width, height ] = [ @graphDomElement.width(), @graphDomElement.height() ]
            [ x, y ] = [ ev.clientX, ev.clientY ]
            [ xNormed, yNormed ] = [ (x - left)/width, (y - top)/height]
            [ xUnit, yUnit ] = [xNormed*2 - 1, yNormed*2 - 1] # xUnit, yUnit \in [-1, 1]

            caster = new three.Raycaster()
            clickV = new three.Vector2 xUnit, -yUnit
            caster.setFromCamera clickV, @camera
            intersects = caster.intersectObjects (node.__threeObj for node in @graph.graphData().nodes)

            node = intersects?[0]?.object?.__data
            if node?
                @emit 'node-clicked', node, event
                @nodeClicked node, ev
    
    
    animate: (now) =>
        requestAnimationFrame @animate
        @controls.update()
        @renderer.render @scene, @camera
        @graph.tickFrame()
    
    nodeClicked: (node, event) =>
        
    
    setRenderSize: (w, h) => 
        @camera.aspect = w / h
        @camera.updateProjectionMatrix()

        @renderer.setSize w, h

export { Tree }
    