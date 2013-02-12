require 'sinatra'
require 'haml'
require 'sass'
require 'compass'
require 'coffee-script'

configure do
	Compass.configuration do |config|
		config.project_path = File.dirname(__FILE__)
    	config.sass_dir = 'views'
  end

  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
  set :scss, Compass.sass_engine_options
end

get '/stylesheets/:name.css' do
	set :views,   File.dirname(__FILE__)    + '/views/scss'
	content_type 'text/css', :charset => 'utf-8'
	scss(:"#{params[:name]}")
end

get '/js/:name.js' do
	set :views,   File.dirname(__FILE__)    + '/views/coffeescript'
	content_type 'text/javascript'
	coffee(:"#{params[:name]}")
end

get '/' do
	File.open('public/index.html', File::RDONLY)
end

get '/playback' do
	File.open('public/playback.html', File::RDONLY)
end