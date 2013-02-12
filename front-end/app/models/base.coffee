$ = window.jQuery

class BaseModel
  @on: ->
    @jQueryEventTarget ?= $({})
    @jQueryEventTarget.on arguments...

  @trigger: ->
    @jQueryEventTarget ?= $({})
    @jQueryEventTarget.trigger arguments...

  constructor: (params = {}) ->
    @[property] = value for property, value of params

  on: ->
    @jQueryEventTarget ?= $({})
    @jQueryEventTarget.on arguments...

  trigger: (eventName, args = []) ->
    @jQueryEventTarget ?= $({})
    @jQueryEventTarget.trigger arguments...
    @constructor.trigger eventName, [@, args...]

module.exports = BaseModel
