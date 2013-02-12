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
    {id: @subject.id, marks: [[{x: 0, y: 0}]]} # TODO!

  send: ->
    socket.emit 'classify', @toJSON()

module.exports = Classification
