io = require 'socket.io-client'

socket = io.connect "//#{location.hostname}:3001"

# socket =
#   on: ->
#     console.log 'SOCKET ON', arguments...

#   emit: ->
#     console.info 'SOCKET EMIT', arguments...

module.exports = socket
