env = process.env.NODE_ENV || 'development'

redisClient = require './lib/redis_client'
_ = require 'underscore'

handler = (req, res) ->
  res.write 200
  res.send()

server = require('http').createServer handler
io = require('socket.io').listen server, {log: false}

require('./lib/socket')(io)


port = process.env.PORT || 3001
server.listen port

console.log "Server listening on port: #{port}"

db = redisClient.create()
pub = redisClient.create()

if env is 'development'
  monit = redisClient.create()
  monit.monitor (err, res) -> console.log "Enter Monitoring Mode"
  monit.on('monitor', (time, args) ->
    console.log("#{time}: #{require('util').inspect(args)}"))

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
    centerPoints = new Array
    keys = new Array

    centerPoints.push centerPoint(points) for points in data.marks
    db.keys "#{data.id}-*", (err, replies) ->
      console.error err if err
      keys.push key.split("-") for key in replies
      for centerPt, index in centerPoints
        closestKey = _(keys).filter((key) ->
          ((key[1] - 20 < centerPt.x) and (key[1] + 20 > centerPt.x) and
           (key[2] - 20 < centerPt.y) and (key[2] + 20 > centerPt.y)))
        multi = db.multi()
        if _.isEmpty closestKey
          marks = {center: [centerPt.x, centerPt.y], marks: data.marks[index]}
          multi.lpush "#{data.id}-#{centerPt.x}-#{centerPt.y}", JSON.stringify(marks)
          multi.sadd data.id, "#{data.id}-#{centerPt.x}-#{centerPt.y}"
        else
          marks = {center: [closestKey[0][1], closestKey[0][2]], marks: data.marks[index]}
          multi.lpush "#{data.id}-#{closestKey[0][1]}-#{closestKey[0][2]}", JSON.stringify(marks)
          multi.ltrim "#{data.id}-#{closestKey[0][1]}-#{closestKey[0][2]}", 0, 99

        multi.exec (err, replies) ->
          console.error err, replies if err

        pub.publish "classification-#{data.id}", JSON.stringify(marks)


  socket.on 'subscribe', (data) ->
    sub = redisClient.create()
    db.smembers data.id, (err, keys) ->
      console.error err if err
      for key in keys
        db.lrange key, 0, 99, (err, classifics) ->
          console.error err if err
          console.log classifics
          socket.emit 'old-classifications', JSON.parse(classifics)
      socket.emit 'loaded-all-classifications', 'done'

    sub.on 'messsage', (channel, data) ->
      socket.emit 'new-classification', JSON.parse(data)

    sub.subscribe "classification-#{data.id}"

    socket.on 'unsubscribe', (data) ->
      sub.unsubscribe()