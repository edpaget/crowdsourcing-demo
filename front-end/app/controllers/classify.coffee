Tracer = require './tracer'
{Controller} = require 'spine'
template = require '../views/classify'
Subject = require '../models/subject'
Classification = require '../models/classification'

class Classify extends Controller
  className: 'classify'

  events:
    'click button[name="classify"]': 'onClickSubmit'
    'click button[name="next"]': 'onClickNext'

  elements:
    'img': 'image'

  tracer: null

  constructor: ->
    super

    @html template

    Subject.on 'select', @onSubjectSelect

  activate: ->
    super
    @tracer = new Tracer()
  
  onSubjectSelect: (e, subject) =>
    @classification = new Classification {subject}

  onClickSubmit: (e) ->
    @classification.marks = @tracer.traces
    console.log "sending: ", @classification
    @classification.send()

  onClickNext: (e) ->
    Subject.next()

module.exports = Classify
