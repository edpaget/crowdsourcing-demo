{Controller} = require 'spine'
template = require '../views/navigation'
Subject = require '../models/subject'
Classification = require '../models/classification'

class Classify extends Controller
  tag: 'nav'

  events:
    'change select[name="subject"]': 'onChooseSubject'

  elements:
    'select[name="subject"]': 'subjectsMenu'

  constructor: ->
    super

    @html template

    @refreshMenu()

    Subject.on 'select', @onSubjectSelect

    Subject.first().select()

  refreshMenu: ->
    @subjectsMenu.empty()

    for subject in Subject.instances
      @subjectsMenu.append "<option value='#{subject.id}'>#{subject.id}</option>"

  onChooseSubject: ->
    subject = Subject.find @subjectsMenu.val()
    subject.select()

  onSubjectSelect: (e, subject) =>
    @subjectsMenu.val subject.id

  onClickNext: (e) ->
    Subject.next()

module.exports = Classify
