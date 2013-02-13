class Tracer

	canvas: null
	stage: null
	img: null
	backgroundImage: null
	update: true
	drawingCanvas: null
	oldPt: null

	isInited: false

	# array of points to send on button press
	currentTrace: []
	currentTime: 0
	traces: []

	# colors could be random
	colors: ["#820020", "#b00001", "#cb003d", "#fa0070", "#f900ad", "#fa00d0", "#560002", "#9b000b", "#d30000", "#fe0000", "#f9001f"]
	currentColor: null
	index: 0

	STROKEWIDTH: 5
	IMAGESCALE: 1.4

	constructor: () ->
		if !@isInited
			@isInited = true
			@canvas = document.getElementById("tracercanvas")
			@stage = new createjs.Stage(@canvas)

			@stage.autoClear = false
			@stage.enableDOMEvents(true)

			createjs.Touch.enable(@stage)

			@addInteraction()
			# TODO: replace this with a smarter load
			@loadImage("http://moonzoo.s3.amazonaws.com/moonzoov2/slices/000005215.png")

	addCurrentPointToTrace: () =>
		# add the current point to the trace
		@currentTrace.push(
				x: @stage.mouseX
				y: @stage.mouseY
				time: createjs.Ticker.getTime()-@currentTime
		)

	addInteraction: () =>
		createjs.Ticker.addListener(@)
		@stage.addEventListener("stagemousedown", @handleMouseDown)
		@stage.addEventListener("stagemouseup", @handleMouseUp)

	cleanTraces: () =>
		console.log "cleanTraces"
		@traces = []
		@drawingCanvas.graphics.clear()
		@update = true

	handleMouseDown: (event) =>
		console.log "down", @drawingCanvas
		# create the new trace
		@currentTrace = []

		@currentColor = @colors[ (@index++) % @colors.length ]
		@oldPt = new createjs.Point(@stage.mouseX, @stage.mouseY)

		@currentTime = createjs.Ticker.getTime()
		@addCurrentPointToTrace()

		@drawingCanvas.graphics
			.setStrokeStyle(@STROKEWIDTH, 'round', 'round')
			.beginStroke(@currentColor)
			.moveTo(@oldPt.x, @oldPt.y)
			# .lineTo(
			# 	@stage.mouseX
			# 	@stage.mouseY
			# )

		@stage.addEventListener("stagemousemove" , @handleMouseMove)

	handleMouseMove: (event) =>
		console.log "move"

		@drawingCanvas.graphics
			# .setStrokeStyle(@STROKEWIDTH, 'round', 'round')
			# .beginStroke(@currentColor)
			# .moveTo(@oldPt.x, @oldPt.y)
			.lineTo(
				@stage.mouseX
				@stage.mouseY
			)

		@oldPt.x = @stage.mouseX
		@oldPt.y = @stage.mouseY

		@addCurrentPointToTrace()

		@update = true

	handleMouseUp: (event) =>
		console.log "up"
		@traces.push(@currentTrace) if (@currentTrace.length > 0)
		@currentTrace = []
		@stage.removeEventListener("stagemousemove" , @handleMouseMove)

	loadImage: (url) =>
		console.log "loading: ", url
		@img = new Image()
		@img.onload = @handleImageLoad
		@img.src = url
		# background = new createjs.Bitmap(url)
		# @stage.addChild(background)
		@update = true

	handleImageLoad: () =>
		console.log " imw:" + @img.width + " imgh:" + @img.height
		# hacky image display (XSS issues)
		# $("#moonimage").css("display","block")
		@backgroundImage = new createjs.Bitmap(@img)
		@backgroundImage.scaleX = @backgroundImage.scaleY = @IMAGESCALE
		
		@stage.addChild(@backgroundImage)
		
		@drawingCanvas = new createjs.Shape()
		@stage.addChild(@drawingCanvas)
		
		@update = true

	tick: () =>
		# this set makes it so the stage only re-renders when an event handler indicates a change has happened.
		if (@update)
			@update = false
			@stage.update()

module.exports = Tracer