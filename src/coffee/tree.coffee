import ThreeForceGraph from 'three-forcegraph'
import * as three from 'three'
import SpriteText from 'three-spritetext'
import OrbitControls from 'three-orbitcontrols'
import { TrackballControls } from 'three/examples/jsm/controls/TrackballControls'
import * as EventEmitter from 'events'
import * as $ from 'jquery'

class CamController extends EventEmitter
    constructor: (@camera,
                @parentDomElement)->
        super()
        @clock = new three.Clock

        @targetDirection = new three.Vector3
        @camera.getWorldDirection @targetDirection

        @lookAtPosition = new three.Vector3 0, 0, 0
        @targetPosition = new three.Vector3 0, 0, 100
        @targetTargetPosition = new three.Vector3 0, 0, 100

        @targetLookAtDistance = 200
        @minTargetLookAtDistance = 50
        @maxTargetLookAtDistance = 1000
        @targetLookAt = new three.Vector3 0, 0, 0
        
        # Position bounds, [min, max]
        @boundsX = undefined
        @boundsY = undefined
        @boundsZ = undefined

        @orbitRotationSpeed = 3
        @pointRotationSpeed = 3
        @scollSpeed = 3

        @positionSeekDampFac = 0.05
        @rotationSeekDampFac = 0.05
        @originOrbitDampFac = 0.01

        @_prevMousePos = undefined
        @_v3repo = (new three.Vector3 for i in [1..10])

        $ @parentDomElement
            .on 'mousemove', @onMouseMove
            .on 'resize', @update
            .on 'mouseup', @onMouseButtonUp
            .on 'mouedown', @onMouseButtonDown
            .on 'contextmenu', (ev) => ev.preventDefault()
            .on 'wheel', @onMouseWheel
    
    setCamPos: (pos) =>
        @camera.position = pos.clone()
        @lookAtPosition = pos.clone()
    
    lookAt: (pos) =>
        @camera.lookAt pos
    
    onMouseMove: (event) =>

        buttons = event.buttons

        leftButton = Boolean buttons & 1
        rightButton = Boolean buttons & 2 
        middleButton = Boolean buttons & 4
        if not (leftButton or rightButton or middleButton)
            @_prevMousePos = undefined
            return

        event.preventDefault()
        event.stopPropagation()

        [x, y] = [event.clientX, event.clientY]
        [dx, dy] = @calcMouseDeltaMovement x, y
        dx_n = dx / @parentDomElement.width() # Normalized, i.e. in [-1, 1]
        dy_n = dy / @parentDomElement.height()
        movementAbs = (dx_n**2 + dy_n**2)**0.5
        
        [
            up,
            right,
            forward,
            cam2LookAtPos,
            lookAtPos2Cam
            mouseOnCam,
            mouseRotAxis
            ] = @_v3repo

        cam =  @camera.position
        cam2LookAtPos.subVectors @lookAtPosition, cam
        @putCamBasis up, right, forward

        up.setLength dy_n
        right.setLength dx_n
        mouseOnCam.addVectors up, right
        # Rotate Camera
        mouseRotAxis.crossVectors forward, mouseOnCam
        mouseRotAxis.normalize()

        # Rotate camera 
        if rightButton
            # Rotate cam2LookAtPos, then set lookAtPos and cam accordingly
            angle = movementAbs * @pointRotationSpeed
            cam2LookAtPos.applyAxisAngle mouseRotAxis, -angle
            @lookAtPosition.addVectors @camera.position, cam2LookAtPos
            @camera.lookAt @lookAtPosition # make it match perfectl
        
        # Move & rotate camera around lookAtPosition
        if leftButton
            angle = movementAbs * @orbitRotationSpeed
            lookAtPos2Cam.subVectors cam, @lookAtPosition
            lookAtPos2Cam.applyAxisAngle mouseRotAxis, angle
            @camera.position.addVectors @lookAtPosition, lookAtPos2Cam
            @camera.lookAt @lookAtPosition

        # Set all targets so cam doesn't move anymore
        @targetPosition.copy cam
        @targetLookAt.copy @lookAtPosition
        @camera.lookAt @lookAtPosition
    
    onMouseWheel: (event) =>
        dy = event.originalEvent.deltaY
        [
            lookAtPosition2Cam,
        ] = @_v3repo

        lookAtPosition2Cam.subVectors @camera.position, @lookAtPosition
        lookAtPosition2Cam.multiplyScalar 1 + dy*@scollSpeed/1000
        lookAtPosition2Cam.clampLength @minTargetLookAtDistance, @maxTargetLookAtDistance
        @targetPosition.addVectors @lookAtPosition, lookAtPosition2Cam

    calcMouseDeltaMovement: (mouseX, mouseY) =>
        @_prevMousePos ?= [mouseX, mouseY]
        [px, py] = @_prevMousePos
        [dx, dy] = [px - mouseX, py - mouseY]
        @_prevMousePos = [ mouseX, mouseY ]
        [dx, dy]

    clearMouseDeltaMovement: =>
        @_prevMousePos = undefined
    
    putCamBasis: (up, right, forward) =>
        @camera.getWorldDirection forward
        up.set 0, 1, 0
        up.applyQuaternion @camera.quaternion
        right.crossVectors up, forward
        right.normalize()

    update: =>
        dt = @clock.getDelta()

        # Update position to reach target
        [ 
            cam2TargetPos,
            cam2LookAtPos,
            origin2lookAtPos,
            look2originTargetPos,
            rotAxis
            lookAt2targetLookAt
            ] = @_v3repo
        
        cam = @camera.position
        cam2TargetPos.subVectors @targetPosition, cam
        cam2TargetPos.multiplyScalar @positionSeekDampFac
        cam.add cam2TargetPos
        @lookAtPosition.add cam2TargetPos

        # Update rotation to see target
        lookAt2targetLookAt.subVectors @targetLookAt, @lookAtPosition
        lookAt2targetLookAt.multiplyScalar @rotationSeekDampFac
        @lookAtPosition.add lookAt2targetLookAt
        @camera.lookAt @lookAtPosition

    setTargetLookAtPosition: (pos) =>
        camToLookAt = new three.Vector3
        camToLookAt.subVectors @camera.position, pos
        camToLookAt.setLength @targetLookAtDistance
        camToLookAt.add pos
        @targetPosition.copy camToLookAt
        @targetLookAt.copy pos 
    



class Graph extends EventEmitter
    constructor: (
            @parentDomElement,
            graphJsonUrl) ->
        super()
        @scene = new three.Scene

        @camera = new three.PerspectiveCamera 75, 1/1, 0.1, 1000
        @camera.far = 1e10
        @camera.position.z = 300

        @renderer = new three.WebGLRenderer { antialias: true, alpha: true}
        @renderer.setClearColor 0x121212, 1
        @parentDomElement.html @renderer.domElement
        @updateSize()

        @control = new CamController @camera, @parentDomElement

        @graph = new ThreeForceGraph()
            .jsonUrl graphJsonUrl
            .nodeThreeObject (node) =>
                # Collision sphere
                colGeo = new three.SphereGeometry 20, 23, 23
                #colMat = new three.MeshBasicMaterial { depthWrite: false, transparent: true, opacity: 0.2}
                colMat = new three.MeshLambertMaterial { color: 0xfffffff, depthWrite: false, transparent: true, opacity: 0}
                colObj = new three.Mesh colGeo, colMat

                # Label
                sprite = new SpriteText ( node.genre ? '🎷' )
                sprite.textHeight = 16
                
                colObj.add sprite

                colObj
        
        @scene.add @graph
        
        @graph.d3Force 'link'
            .distance (node) => 250
        
        @clock = new three.Clock

        window.addEventListener 'resize', @updateSize

        # These emit click events if delta movement is low
        @mouseButtonDownPos = [0, 0]
        window.addEventListener 'mousedown', @onMouseButtonDown
        window.addEventListener 'mouseup', @onMouseButtonUp

        @on 'click', @onClickEvent
        @on 'node-clicked', @onNodeClicked
    
    onMouseButtonDown: (ev) =>
        @mouseButtonDownPos = [ev.clientX, ev.clientY]
    
    onMouseButtonUp: (ev) =>
        [downX, downY] = @mouseButtonDownPos
        [upX, upY] = [ev.clientX, ev.clientY]
        delta = ((upY - downY)**2 + (upX - downX)**2) ** 0.5
        if delta <= 2 and @coordIsOnParentDom [upX, upY] 
            @emit 'click', ev
    
    coordIsOnParentDom: ([x, y]) =>
        [pW, pH] = [ @parentDomElement.width(), @parentDomElement.height() ]
        offset = @parentDomElement.offset()
        [pX, pY] = [ offset.left, offset.top ]
        pX <= x <= pX + pW and pY <= y <= pY + pH

    # Emits 'node clicked', 'background-clicked' etc
    onClickEvent: (ev) =>
        # Calculate mouse click x, y in range [-1, 1]
        { top, left } = @parentDomElement.position()
        [ width, height ] = [ @parentDomElement.width(), @parentDomElement.height() ]
        [ x, y ] = [ ev.clientX, ev.clientY ]
        [ xNormed, yNormed ] = [ (x - left)/width, (y - top)/height]
        [ xUnit, yUnit ] = [xNormed*2 - 1, yNormed*2 - 1] # xUnit, yUnit \in [-1, 1]

        # Cast ray from camera
        caster = new three.Raycaster()
        clickV = new three.Vector2 xUnit, -yUnit
        caster.setFromCamera clickV, @camera
        intersects = caster.intersectObjects (node.__threeObj for node in @graph.graphData().nodes)

        # Check if ray cast hit a node
        node = intersects?[0]?.object?.__data
        if node?
            @emit 'node-clicked', node, event
        else
            @emit 'background-clicked', event
    
    loop: =>
        requestAnimationFrame @loop
        @control.update()
        @renderer.render @scene, @camera
        @graph.tickFrame()
    
    updateSize: =>
        [w, h] = [@parentDomElement.width(), @parentDomElement.height()]
        @emit 'size-changed', w, h

        @camera.aspect = w / h
        @camera.updateProjectionMatrix()
        @renderer.setSize w, h
        
        console.log $(@renderer.domElement).attr 'height'

    
    onNodeClicked: (node, event) =>
        nodePos = node?.__threeObj?.position
        if nodePos?
            @control.setTargetLookAtPosition nodePos
    
    _getNeighboursOf: (node) =>
        nodeId = node.id
        res = []
        for link in @graph.graphData().links
            if link.source.id is nodeId
                res.push link.target
            else if link.target.id is nodeId
                res.push link.source
        res

export { Graph }
    