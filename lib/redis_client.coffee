module.exports = 
  create: (db) ->
    redis = require 'redis'
    env = process.env.NODE_ENV or 'development'
    db = db or 1

    if env is 'development' or env is 'staging'
      client = redis.createClient 6379, 'localhost'
    else
      rtg = require('url').parse process.env.REDISTOGO_URL
      client = redis.createClient rtg.port, rtg.hostname
      # NOTE: IMPORTANT! in nodejitsu the password has a : symbol
      # Added an env var for the password
      client.auth process.env.REDIS_PASSWORD, (err) ->
        if err
          console.error err
          throw err

    client.on 'error', (args...) ->
      console.error 'Danger Will Robinson! ', args
    client.select db
    return client