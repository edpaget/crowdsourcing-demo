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
sub = redisClient.create()

if env is 'development-monitor'
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

fixBadJSON = (json) ->
  if _.isArray json
    for item,index in json
      json[index] = JSON.parse(item)
  json


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
          console.log parseFloat(key[1]) - 30, centerPt.x, parseFloat(key[1]) + 30
          ((parseFloat(key[1]) - 30 < centerPt.x) and (parseFloat(key[1]) + 30 > centerPt.x) and
           (parseFloat(key[2])- 30 < centerPt.y) and (parseFloat(key[2]) + 30 > centerPt.y)))
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
        console.log "classification-#{data.id}"


  socket.on 'subscribe', (data) ->
    db.smembers data.id, (err, keys) ->
      console.error err if err
      for key in keys
        if key is _.last(keys)
          db.lrange key, 0, 99, (err, classifics) ->
            console.error err if err
            socket.emit 'classification', fixBadJSON(classifics)
            socket.emit 'loaded-old-classifications', 'done' 
        else
          db.lrange key, 0, 99, (err, classifics) ->
            console.error err if err
            socket.emit 'classification', fixBadJSON(classifics)

    sub.on 'message', (channel, data) ->
      console.log 'here'
      socket.emit 'classification', [JSON.parse(data)]
      socket.emit 'update', 'done'

    sub.subscribe "classification-#{data.id}"
    console.log "classification-#{data.id}"

    socket.on 'unsubscribe', (data) ->
      sub.unsubscribe()