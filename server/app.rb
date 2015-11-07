require 'eventmachine'
require 'sinatra/base'

module Server
  # TODO: Handle 404s, etc.
  #
  class App < Sinatra::Base
    configure do
      set :root, File.expand_path('../..', __FILE__)
      set :threaded, false
    end

    get '/hello' do
      'Hello World'
    end
  end
end
