{Controller} = require 'spine'
template = require '../views/navigation'
Subject = require '../models/subject'
Classification = require '../models/classification'

class Classify extends Controller
  tag: 'nav'

  events:
    'change select[name="subject"]': 'onChooseSubject'
    'change select[name="playback"]': 'onChoosePlayback'

  elements:
    'select[name="subject"]': 'subjectsMenu'
    'select[name="playback"]': 'playbackMenu'

  constructor: ->
    super

    @html template

    @refreshMenu()

    @populatePlayback()

    Subject.on 'select', @onSubjectSelect

    Subject.first().select()

  refreshMenu: ->
    @subjectsMenu.empty()

    for subject in Subject.instances
      @subjectsMenu.append "<option value='#{subject.id}'>#{subject.id}</option>"

  populatePlayback: ->
    @playbackMenu.empty()

    @playbackMenu.append "<option value='0'>Real time</option>"
    @playbackMenu.append "<option value='5'>5 past</option>"
    @playbackMenu.append "<option value='10'>10 past</option>"
    @playbackMenu.append "<option value='100'>100 past</option>"

  onChooseSubject: ->
    subject = Subject.find @subjectsMenu.val()
    subject.select()

  onChoosePlayback: ->
    playbackType = @playbackMenu.val()
    console.log playbackType

  onSubjectSelect: (e, subject) =>
    @subjectsMenu.val subject.id

  onClickNext: (e) ->
    Subject.next()

module.exports = Classify
