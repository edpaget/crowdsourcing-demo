require './vendor/jquery'

Subject = require './models/subject'
{Stack} = require 'spine/lib/manager'
Route = require 'spine/lib/route'
Classify = require './controllers/classify'
Results = require './controllers/results'

for i in [0...10]
  new Subject
    id: i
    location: "//placehold.it/100x100.png&text=#{i}"

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
