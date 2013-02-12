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

averageCricles = (data) ->
  averages = new Array
  averages.push(averageCircle circle) for circle in data
  averages

averageCircle = (data) ->
  data = _.flatten data
  xMean = _(data).chain().pluck('x').reduce(((memo, num) -> memo + num), 0) / 2
  yMean = _(data).chain().pluck('y').reduce(((memo, num) -> memo + num), 0) / 2

  radius1 = distancePoints(data[0], {x: xMean, y: yMean})
  radius2 = distnacePoints(data[length - 1], {x: xMean, y: yMean})
  radiusMean = (radius1 + radius2) / 2

  {center: {x: xMean, y:yMean}, radius: radiusMean}

io.sockets.on 'connection', (socket) ->
  socket.on 'classify', (data) ->
    db.publish "classification-#{data.id}", data.classification
    db.lpush data.id, data.classification

  socket.on 'subscribe', (data) ->
    classifications = db.get data.id

    socket.emit 'old-classifications', 
      classifications: classifications
      averages: averageCircles classificiations 
    subscription = db.subscribe "classification-#{data.id}"
    subscription.on 'error', (err) ->
      console.error err
    subscription.on 'messsage', (channel, data) ->
      socket.emit 'new-classification', 
        classifications: data
        averages: averageCircles(classifications.push data)

    socket.on 'unsubscribe', (data) ->
      subscription.off 'message'