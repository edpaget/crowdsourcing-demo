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

  constructor: ->
    super

    @html template

    Subject.on 'select', @onSubjectSelect

  onSubjectSelect: (e, subject) =>
    @classification = new Classification {subject}
    @image.attr src: subject.location

  onClickSubmit: (e) ->
    @classification.send()

  onClickNext: (e) ->
    Subject.next()

module.exports = Classify
