BaseModel = require './base'

class Subject extends BaseModel
  @instances: []

  @first: ->
    @instances[0]

  @next: ->
    @instances[1].select()

  @find: (id) ->
    return instance for instance in @instances when instance.id is id

  id: ''
  location: ''

  constructor: (params) ->
    super
    @constructor.instances.push @

  select: ->
    index = i for instance, i in @constructor.instances when instance is @
    @constructor.instances.push @constructor.instances.splice(0, index)...
    @trigger 'select'

module.exports = Subject
window.Subject = Subject
