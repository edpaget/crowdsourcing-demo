io = require 'socket.io-client'

socket = io.connect "//#{location.hostname}:#{location.port}"

# socket =
#   on: ->
#     console.log 'SOCKET ON', arguments...

#   emit: ->
#     console.info 'SOCKET EMIT', arguments...

module.exports = socket
