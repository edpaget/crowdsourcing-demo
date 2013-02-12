require './vendor/jquery'

window.createjs ?= {}
require './vendor/easeljs.js'

Subject = require './models/subject'
Navigation = require './controllers/navigation'
{Stack} = require 'spine/lib/manager'
Route = require 'spine/lib/route'
Classify = require './controllers/classify'
Results = require './controllers/results'

for i in [0...10]
  new Subject
    id: "S_#{i}"
    location: "//placehold.it/800x544.png&text=#{i}"

navigation = new Navigation
navigation.appendTo document.body

window.stack = new Stack
  controllers:
    classify: Classify
    results: Results

  routes:
    '/': 'classify'
    '/classify': 'classify'
    '/results': 'results'

  default: 'classify'

window.stack.el.appendTo document.body

Route.setup()

Subject.first().select()
