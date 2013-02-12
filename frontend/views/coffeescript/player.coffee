class Player

	canvas: null
	stage: null
	img: null
	backgroundImage: null
	update: true
	drawingCanvas: null
	oldPt: null
	oldMidPt: null

	# array of points to send on button press
	currentTrace: []
	currentTime: 0
	currentPoint: 0
	traces: []
	isDrawing: false
	lastDraw: 0

	# colors could be random
	averageColor: "#820020"
	traceColor: "rgba(255,255,0,.5)"
	index: 0

	STROKEWIDTH: 5

	constructor: () ->
		@canvas = document.getElementById("tracercanvas")
		@stage = new createjs.Stage(@canvas)

		@stage.autoClear = false
		@stage.enableDOMEvents(true)

		createjs.Ticker.setFPS(60);

		@addInteraction()
		# TODO: replace this with a smarter load
		@loadImage("http://moonzoo.s3.amazonaws.com/moonzoov2/slices/000005215.png")
		@loadTraces("/js/test.json")

	addInteraction: () =>
		createjs.Ticker.addListener(@)

	startDrawingTraces: () =>
		@currentTrace = 0
		@currentTime = createjs.Ticker.getTime()
		@currentPoint = 1
		@isDrawing = true
		@lastDraw = 0

	drawTrace: () =>
		trace = @traces[@currentTrace]
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
		

	handleMouseDown: (event) =>
		# console.log "down"
		# create the new trace
		@currentTrace = []

		@currentColor = @colors[ (@index++) % @colors.length ]
		@oldPt = new createjs.Point(@stage.mouseX, @stage.mouseY)
		@oldMidPt = @oldPt

		@currentTime = createjs.Ticker.getTime()
		@addCurrentPointToTrace()

		@stage.addEventListener("stagemousemove" , @handleMouseMove)

	handleMouseMove: (event) =>
		# console.log "move"
		@midPt = new createjs.Point(@oldPt.x + @stage.mouseX>>1, @oldPt.y + @stage.mouseY>>1)

		@drawingCanvas.graphics #.clear()
			.setStrokeStyle(@STROKEWIDTH, 'round', 'round')
			.beginStroke(@currentColor)
			.moveTo(@midPt.x, @midPt.y)
			.curveTo(
				@oldPt.x
				@oldPt.y
				@oldMidPt.x
				@oldMidPt.y
			)

		@oldPt.x = @stage.mouseX
		@oldPt.y = @stage.mouseY

		@oldMidPt.x = @midPt.x
		@oldMidPt.y = @midPt.y

		@addCurrentPointToTrace()

		@stage.update()

	loadImage: (url) =>
		console.log "loading: ", url
		@img = new Image()
		@img.onload = @handleImageLoad
		@img.src = url
		# background = new createjs.Bitmap(url)
		# @stage.addChild(background)
		@update = true

	loadTraces: (url) =>
		$.getJSON(url,
			(data) =>
				@traces = data
				console.log "traces: ", @traces
				@startDrawingTraces()
			)

	handleImageLoad: () =>
		console.log " imw:" + @img.width + " imgh:" + @img.height
		# hacky image display (XSS issues)
		# $("#moonimage").css("display","block")
		@backgroundImage = new createjs.Bitmap(@img)
		@stage.addChild(@backgroundImage)
		
		@drawingCanvas = new createjs.Shape()
		@stage.addChild(@drawingCanvas)
		
		@update = true

	tick: () =>
		# this set makes it so the stage only re-renders when an event handler indicates a change has happened.
		if (@update)
			@update = false
			@stage.update()
		if (@isDrawing && @drawingCanvas)
			@drawTrace()
			@currentPoint++
			if (@currentPoint >= @traces[@currentTrace].length)
				@currentPoint = 1
				@currentTrace++
				@isDrawing = false if @currentTrace >= @traces.length

$ ->
	zooPlayer = new Player()