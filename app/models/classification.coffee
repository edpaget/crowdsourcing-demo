socket = require '../lib/socket'

class Mark
  points: null

  constructor: ->
    @points = []

  toJSON: ->
    {@points}

class Classification
  subject: null
  marks: null

  constructor: (params) ->
    {@subject} = params
    @marks = []

  toJSON: ->
    {id: @subject.id, @marks}

  send: ->
    socket.emit 'classify', @toJSON()

module.exports = Classification
