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
    socket.on 'classification', @onNewClassification
    socket.on 'loaded-old-classifications', @onLoadedAll

  activate: =>
    super
    @player = new Player() if @player is null
    socket.emit 'subscribe', id: Subject.first().id

  onSubjectSelect: (e, subject) =>

  onLoadedAll: (data) =>
    @player.startDrawingTraces()

  onNewClassification: (data) =>
    console.log 'here'
    @player.loadTraces data

  deactivate: ->
    super
    socket.emit 'unsubscribe', id: Subject.first().id

module.exports = Results
