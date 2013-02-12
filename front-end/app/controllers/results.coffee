Player = require './player'
{Controller} = require 'spine'
template = require '../views/results'
socket = require '../lib/socket'
Subject = require '../models/subject'

class Results extends Controller
  className: 'results'

  player: null

  constructor: ->
    super

    @html template

    Subject.on 'select', @onSubjectSelect
    socket.on 'old-classifications', @onOldClassifications
    socket.on 'new-classification', @onNewClassification

  activate: ->
    super
    @player = new Player() if @player is null
    socket.emit 'subscribe', id: Subject.first().id

  onSubjectSelect: (e, subject) =>

  onOldClassifications: (data) ->
    # TODO: Draw the initial classifications

  onNewClassification: (data) ->
    # TODO: Add a classificaiton drawing, update the average

  deactivate: ->
    super
    socket.emit 'unsubscribe', id: Subject.first().id

module.exports = Results