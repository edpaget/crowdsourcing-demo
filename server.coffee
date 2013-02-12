redisClient = require './lib/redis_client'
_ = require 'underscore'

handler = (req, res) ->
  res.write 200
  rese.send()

server = require('http').createServer handler
io = require('socket.io').listen server, {log: false}

require('./lib/socket')(io)

port = process.env.PORT || 3001
server.listen port

console.log "Server listening on port: #{port}"

db = redisClient.create()

distancePoints = (left, right) ->
  Math.sqrt(Math.pow(left.x - right.x, 2), Math.pow(left.y - right.y, 2))

centerPoint = (points) ->
  xSum = _(points).chain().pluck('x').reduce(((memo, num) -> memo + num), 0).value()
  ySum = _(points).chain().pluck('y').reduce(((memo, num) -> memo + num), 0).value()

  xMean = xSum / points.length
  yMean = ySum / points.length

  {x: xMean, y: yMean}

io.sockets.on 'connection', (socket) ->
  socket.on 'classify', (data) ->
    console.log {data}
    centerPoints = new Array
    keys = new Array

    centerPoints.push centerPoint(points) for points in data.marks
    keys.push key.split("-") for key in db.keys("#{data.id}-*")
    for centerPoint, index in centerPoints
      closestKey = _(keys).filter((key) ->
        ((key[1] - 10 < centerPoint.x) and (key[1] + 10 > centerPoint.x) and
         (key[2] - 10 < centerPoint.y) and (key[2] + 10 > centerPoint.y)))
      if _.isEmpty closestKey
        db.lpush "#{data.id}-#{centerPoint.x}-#{centerPoint.y}", data.marks[index]
        db.lpush data.id, "#{data.id}-#{centerPoint.x}-#{centerPoint.y}"
      else
        db.lpush "#{data.id}-#{closestKey[1]}-#{closestKey[2]}", data.marks[index]
        db.ltrim 0, 99
    db.publish "classification-#{data.id}", db.get(data.id)

  socket.on 'subscribe', (data) ->
    classifications = new Array
    classificationKeys = db.get data.id
    classifications.push db.get(key) for key in classificationKeys

    socket.emit 'old-classifications', classifications

    subscription = db.subscribe "classification-#{data.id}"
    subscription.on 'error', (err) ->
      console.error err
    subscription.on 'messsage', (channel, data) ->
      newClassifications = new Array
      newClassifications.push db.get(key)[0] for key in data
      socket.emit 'new-classification', _.difference(classifications, allClassifications)

    socket.on 'unsubscribe', (data) ->
      subscription.off 'message'