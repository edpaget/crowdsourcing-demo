getCardinalPoints = (points) ->
  xs = []
  ys = []

  for {x, y}, i in points
    xs.push x
    ys.push y

  minY = Math.min ys...
  maxX = Math.max xs...
  maxY = Math.max ys...
  minX = Math.min xs...

  north = points[ys.indexOf minY]
  east = points[xs.indexOf maxX]
  south = points[ys.indexOf maxY]
  west = points[xs.indexOf minX]

  [north, east, south, west]

averagePoints = (points) ->
  totalX = 0
  totalY = 0

  for item in points
    totalX += item.x
    totalY += item.y

  x: totalX / points.length
  y: totalY / points.length

drawBlob = ([n, e, s, w], canvas) ->
  hOffset = (e.x - w.x) * 0.05
  vOffset = (s.y - n.y) * 0.05

  pathData = """
    M #{n.x} #{n.y}
    Q #{e.x - hOffset} #{n.y + vOffset} #{e.x} #{e.y}
    Q #{e.x - hOffset} #{s.y - vOffset} #{s.x} #{s.y}
    Q #{w.x + hOffset} #{s.y - vOffset} #{w.x} #{w.y}
    Q #{w.x + hOffset} #{n.y + vOffset} #{n.x} #{n.y}
  """

  graphics = canvas.graphics
  graphics.setStrokeStyle 2, 'round', 'round'
  graphics.beginStroke 'red'
  graphics.moveTo n.x, n.y
  graphics.quadraticCurveTo e.x - hOffset, n.y + vOffset, e.x, e.y
  graphics.quadraticCurveTo e.x - hOffset, s.y - vOffset, s.x, s.y
  graphics.quadraticCurveTo w.x + hOffset, s.y - vOffset, w.x, w.y
  graphics.quadraticCurveTo w.x + hOffset, n.y + vOffset, n.x, n.y

drawAverage = (classifications, canvas) ->
  cardinals = (getCardinalPoints classification for classification in classifications)

  average = [
    averagePoints (cardinal[0] for cardinal in cardinals)
    averagePoints (cardinal[1] for cardinal in cardinals)
    averagePoints (cardinal[2] for cardinal in cardinals)
    averagePoints (cardinal[3] for cardinal in cardinals)
  ]

  drawBlob average, canvas

module.exports = drawAverage
