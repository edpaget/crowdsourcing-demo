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
	averages: []
	isDrawing: false
	lastDraw: 0

	# colors could be random
	averageColor: "#ff0000"
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

	drawAverages: () =>
		for average in @averages
			@drawingCanvas.graphics #.clear()
				.setStrokeStyle(@STROKEWIDTH, 'round', 'round')
				.beginStroke(@averageColor)
				.moveTo(average[0].x, average[0].y)
				.curveTo(
					average[1].x
					average[1].y
					average[2].x
					average[2].y
				)
				.curveTo(
					average[3].x
					average[3].y
					average[0].x
					average[0].y
				)

		@update = true
		

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
				@traces = data.classifications
				@averages = data.averages
				# console.log "traces: ", data, @traces
				@startDrawingTraces()
			)

	handleImageLoad: () =>
		console.log " imw:" + @img.width + " imgh:" + @img.height
		# hacky image display (XSS issues)
		# $("#moonimage").css("display","block")
		@backgroundImage = new createjs.Bitmap(@img)
		@backgroundImage.scaleX = @backgroundImage.scaleY = 1.5
		
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
				if @currentTrace >= @traces.length
					@isDrawing = false
					@drawAverages()

$ ->
	zooPlayer = new Player()