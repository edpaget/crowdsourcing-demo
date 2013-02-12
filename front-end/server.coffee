CoffeeScript = require 'coffee-script'
HawServer = require 'haw/lib/server'

server = new HawServer root: __dirname

server.serve +process.env.PORT + 100 || 8001
