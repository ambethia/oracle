require 'eventmachine'
require 'sinatra/base'
require 'faye'
require 'redis'

require_relative 'mouse_move_handler'

# TODO: Handle 404s, etc.
#
class App < Sinatra::Base
  configure do
    set :threaded, false
  end

  get '/hello' do
    'Hello World'
  end
end
