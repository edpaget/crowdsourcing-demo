{Controller} = require 'spine'
template = require '../views/results'
socket = require '../lib/socket'
Subject = require '../models/subject'

class Results extends Controller
  elements:
    'img': 'image'

  constructor: ->
    super

    @html template

    socket.on 'old-classifications', @onOldClassifications
    socket.on 'new-classification', @onNewClassification

  activate: ->
    super

    @image.attr src: Subject.first().location
    socket.emit 'subscribe', id: Subject.first().id

  onOldClassifications: (data) ->
    # TODO: Draw the initial classifications

  onNewClassification: (data) ->
    # TODO: Add a classificaiton drawing, update the average

  deactivate: ->
    super

    socket.emit 'unsubscribe', id: Subject.first().id

module.exports = Results
