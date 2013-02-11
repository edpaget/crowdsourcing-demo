BaseModel = require './base'

class Subject extends BaseModel
  @instances: []

  @first: ->
    @instances[0]

  @next: ->
    throw new Error 'No subjects!' if @instances.length is 0
    @instances.push @instances.shift()
    @trigger 'select', [@first()]

  id: ''
  location: ''

  constructor: (params) ->
    super
    @constructor.instances.push @

module.exports = Subject
