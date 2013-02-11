class Tracer

	canvas: null
	stage: null
	img: null
	backgroundImage: null
	update: true
	drawingCanvas: null
	oldPt: null
	oldMidPt: null

	# colors could be random
	colors: ["#828b20", "#b0ac31", "#cbc53d", "#fad779", "#f9e4ad", "#faf2db", "#563512", "#9b4a0b", "#d36600", "#fe8a00", "#f9a71f"]
	currentColor: null
	index: 0

	STROKEWIDTH: 5

	constructor: () ->
		console.log "hi"
		@canvas = document.getElementById("tracercanvas")
		@stage = new createjs.Stage(@canvas)

		@stage.autoClear = false
		@stage.enableDOMEvents(true)

		createjs.Touch.enable(@stage)

		@addInteractionListeners()
		# TODO: replace this with a smarter load
		@loadImage("http://moonzoo.s3.amazonaws.com/v21/slices/000019052.jpg")

	addInteractionListeners: () =>
		@stage.addEventListener("stagemousedown", @handleMouseDown)
		@stage.addEventListener("stagemouseup", @handleMouseUp)

	handleMouseDown: (event) =>
		console.log "down"
		@currentColor = @colors[ (@index++) % @colors.length ]
		@oldPt = new createjs.Point(@stage.mouseX, @stage.mouseY)
		@oldMidPt = @oldPt
		@stage.addEventListener("stagemousemove" , @handleMouseMove)

	handleMouseMove: (event) =>
		console.log "move"
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

		@stage.update()

	handleMouseUp: (event) =>
		console.log "up"
		@stage.removeEventListener("stagemousemove" , @handleMouseMove);

	loadImage: (url) =>
		console.log "loading: ", url
		@img = new Image() #document.getElementById("moonimage")
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
		
		createjs.Ticker.addListener(window)
		@update = true

	tick: () =>
		# this set makes it so the stage only re-renders when an event handler indicates a change has happened.
		if (@update)
			@update = false
			@stage.update()

$ ->
	zooTracer = new Tracer