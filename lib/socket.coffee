redisCli = require './redis_client'
RedisStore = require 'socket.io/lib/stores/redis'

module.exports = (io) ->
  io.configure ->
    io.set 'origins', '*:*'
    io.set 'transports', ['websocket', 'xhr-polling', 'jsonp-polling']
    io.set 'polling duration', 10
    io.set 'store', new RedisStore
      redis: require 'redis'
      redisPub: redisCli.create()
      redisSub: redisCli.create()
      redisClient: redisCli.create()

    io.enable 'browser client minification'
