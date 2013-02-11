io = require 'socket.io-client'

# socket = io.connect() # TODO

socket =
  emit: ->
    console.info 'EMIT', arguments...

module.exports = socket
