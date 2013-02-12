{Controller} = require 'spine'
template = require '../views/results'
socket = require '../lib/socket'
Subject = require '../models/subject'

class Results extends Controller
  className: 'results'

  elements:
    'img': 'image'

  constructor: ->
    super

    @html template

    Subject.on 'select', @onSubjectSelect
    socket.on 'old-classifications', @onOldClassifications
    socket.on 'new-classification', @onNewClassification

  activate: ->
    super
    socket.emit 'subscribe', id: Subject.first().id

  onSubjectSelect: (e, subject) =>
    @image.attr src: subject.location

  onOldClassifications: (data) ->
    # TODO: Draw the initial classifications

  onNewClassification: (data) ->
    # TODO: Add a classificaiton drawing, update the average

  deactivate: ->
    super
    socket.emit 'unsubscribe', id: Subject.first().id

module.exports = Results
