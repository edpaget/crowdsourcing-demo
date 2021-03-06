_ = require 'underscore'
drawAverageCircle = require '../lib/draw-average-circle'

class Player

  canvas: null
  stage: null
  img: null
  backgroundImage: null
  update: true
  drawingCanvas: null
  averageCanvas: null
  oldPt: null
  oldMidPt: null

  # array of points to send on button press
  currentTrace: []
  currentTime: 0
  currentPoint: 0
  traces: []
  averages: []
  isDrawing: false
  lastDraw: 0

  # colors could be random
  averageColor: "#ff0000"
  traceColor: "rgba(255,255,0,.4)"
  index: 0

  STROKEWIDTH: 3
  IMAGESCALE: 1.4

  constructor: () ->
    @canvas = document.getElementById("playercanvas")
    @stage = new createjs.Stage(@canvas)
    @traces = []
    @clusters = {}
    @started = false

    @stage.autoClear = false
    @stage.enableDOMEvents(true)

    createjs.Ticker.setFPS(60);

    @addInteraction()
    # TODO: replace this with a smarter load
    @loadImage("http://moonzoo.s3.amazonaws.com/moonzoov2/slices/000005215.png")

  addInteraction: =>
    createjs.Ticker.addListener(@)

  startDrawingTraces: =>
    @currentTrace = 0
    @currentTime = createjs.Ticker.getTime()
    @currentPoint = 1
    @isDrawing = true
    @lastDraw = 0
    @started = true

  updateTraces: =>
    @isDrawing = true

  drawTrace: () =>
    trace = @traces[@currentTrace]
    unless _.isUndefined trace
      point = trace[@currentPoint]
      prevpoint = trace[@currentPoint-1]

      @drawingCanvas.graphics #.clear()
        .setStrokeStyle(@STROKEWIDTH, 'round', 'round')
        .beginStroke(@traceColor)
        .moveTo(prevpoint.x, prevpoint.y)
        .lineTo(
          point.x
          point.y
        )

      @update = true

  drawAverages: () =>
    @averageCanvas.graphics.clear()
    for key, cluster of @clusters
    	drawAverageCircle cluster, @averageCanvas
    @update = true

  loadImage: (url) =>
    console.log "loading: ", url
    @img = new Image()
    @img.onload = @handleImageLoad
    @img.src = url
    @update = true

  loadTraces: (data) =>
    for datum in data
      @traces.push datum.marks
      clusterKey = datum.center.join('-')
      if _.isArray @clusters[datum.center.join('-')]
        @clusters[clusterKey].push datum.marks
      else
        @clusters[clusterKey] = new Array
        @clusters[clusterKey].push datum.marks

  handleImageLoad: () =>
    console.log " imw:" + @img.width + " imgh:" + @img.height
    @backgroundImage = new createjs.Bitmap(@img)
    @backgroundImage.scaleX = @backgroundImage.scaleY = @IMAGESCALE
    
    @stage.addChild(@backgroundImage)
    
    @drawingCanvas = new createjs.Shape()
    @stage.addChild(@drawingCanvas)
    
    @averageCanvas = new createjs.Shape()
    @stage.addChild(@averageCanvas)
    
    @update = true

  empty: =>
    console.log 'empty'
    @traces = []
    @clusters = []
    @drawingCanvas.graphics.clear()
    @averageCanvas.graphics.clear()
    @update = true
    # TODO: this should also clear the RedisDB

  tick: () =>
    # this set makes it so the stage only re-renders when an event handler indicates a change has happened.
    if (@update)
      @update = false
      @stage.update()
    if (@isDrawing && @drawingCanvas and (not _.isUndefined(@traces[@currentTrace])))
      @drawTrace()
      @currentPoint++
      if (@currentPoint >= @traces[@currentTrace].length)
        @currentPoint = 1
        @currentTrace++
        # @currentTrace++ if @traces[@currentTrace].length is 1
        if @currentTrace >= @traces.length
          @isDrawing = false
          # console.log @isDrawing
          @drawAverages()

module.exports = Player