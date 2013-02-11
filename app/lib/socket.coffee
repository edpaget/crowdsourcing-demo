io = require 'socket.io-client'

# socket = io.connect() # TODO

socket =
  on: ->
    console.log 'SOCKET ON', arguments...

  emit: ->
    console.info 'SOCKET EMIT', arguments...

module.exports = socket
