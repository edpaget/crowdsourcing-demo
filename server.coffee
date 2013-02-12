env = process.env.NODE_ENV || 'development'

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
    publish = (err, replies) ->
      console.error err if err
      db.smembers data.id, (err, replies) ->
        console.error err if err
        console.log "Replies: ", replies, "\n"
        db.publish "classification-#{data.id}", replies

    console.log data.marks
    centerPoints = new Array
    keys = new Array

    centerPoints.push centerPoint(points) for points in data.marks
    db.keys "#{data.id}-*", (err, replies) ->
      console.error err if err
      keys.push key.split("-") for key in replies
      for centerPt, index in centerPoints
        closestKey = _(keys).filter((key) ->
          ((key[1] - 10 < centerPt.x) and (key[1] + 10 > centerPt.x) and
           (key[2] - 10 < centerPt.y) and (key[2] + 10 > centerPt.y)))
        multi = db.multi()
        if _.isEmpty closestKey
          multi.lpush "#{data.id}-#{centerPt.x}-#{centerPt.y}", data.marks[index]
          multi.sadd data.id, "#{data.id}-#{centerPt.x}-#{centerPt.y}"
          multi.exec publish
        else
          multi.lpush "#{data.id}-#{closestKey[0][1]}-#{closestKey[0][2]}", data.marks[index]
          multi.ltrim "#{data.id}-#{closestKey[0][1]}-#{closestKey[0][2]}", 0, 99
          multi.exec publish

  socket.on 'subscribe', (data) ->
    db.get data.id, (err, keys) ->
      console.error err if err
      db.mget keys, (err, classfics) ->
        socket.emit 'old-classifications', classifics

    db.on 'messsage', (channel, data) ->
      db.mget 'data', (err, replies) ->
        console.error err if err
      socket.emit 'new-classification', _.difference(classifications, allClassifications)
      db.subscribe "classification-#{data.id}"

    socket.on 'unsubscribe', (data) ->
      db.unsubscribe()