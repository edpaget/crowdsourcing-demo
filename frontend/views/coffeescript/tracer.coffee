class Tracer

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
	traces: []

	# colors could be random
	colors: ["#820020", "#b00001", "#cb003d", "#fa0070", "#f900ad", "#fa00d0", "#560002", "#9b000b", "#d30000", "#fe0000", "#f9001f"]
	currentColor: null
	index: 0

	STROKEWIDTH: 5

	constructor: (moonzoourl) ->
		console.log "hi"
		@canvas = document.getElementById("tracercanvas")
		@stage = new createjs.Stage(@canvas)

		@stage.autoClear = false
		@stage.enableDOMEvents(true)

		createjs.Touch.enable(@stage)

		@addInteraction()
		# TODO: replace this with a smarter load
		@loadImage(moonzoourl)

	addCurrentPointToTrace: () =>
		# add the current point to the trace
		@currentTrace.push(
				x: @stage.mouseX
				y: @stage.mouseY
				time: createjs.Ticker.getTime()
		)

	addInteraction: () =>
		$("#button").on("click", @sendTraces)
		createjs.Ticker.addListener(@)
		@stage.addEventListener("stagemousedown", @handleMouseDown)
		@stage.addEventListener("stagemouseup", @handleMouseUp)

	sendTraces: ()=>
		console.log "send: ", @traces
		return false

	handleMouseDown: (event) =>
		# console.log "down"
		# create the new trace
		@currentTrace = []

		@currentColor = @colors[ (@index++) % @colors.length ]
		@oldPt = new createjs.Point(@stage.mouseX, @stage.mouseY)
		@oldMidPt = @oldPt

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

	handleMouseUp: (event) =>
		@traces.push(@currentTrace) if (@currentTrace != @traces[@traces.length-1])
		@stage.removeEventListener("stagemousemove" , @handleMouseMove);

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
		@stage.addChild(@backgroundImage)
		
		@drawingCanvas = new createjs.Shape()
		@stage.addChild(@drawingCanvas)
		
		@update = true

	tick: () =>
		# this set makes it so the stage only re-renders when an event handler indicates a change has happened.
		if (@update)
			@update = false
			@stage.update()

$ ->
	zooTracer = new Tracer("http://moonzoo.s3.amazonaws.com/moonzoov2/slices/000005215.png")