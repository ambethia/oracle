require 'eventmachine'
require 'sinatra/base'
require 'faye/websocket'
# require 'redis'
# require 'thin'

# require_relative 'mouse_move_handler'

# Fiber.new {
#   puts "in fiber"
#   EM.run do
#
#     puts "in em"
#     client = Faye::Client.new("http://localhost:#{ENV['PORT']}/bayeux")
#     client.subscribe '/move' do |msg|
#       puts msg
#     end
# end
# }

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

# EM.run do
#   dispatch = Rack::Builder.app do
#     use Faye::RackAdapter, mount: '/bayeux', timeout: 25
#     map '/' do
#       run App.new
#     end
#   end

  # redis = Redis.new(driver: :synchrony)
  # Rack::Server.start(
  #   Port:    ENV['PORT'],
  #   app:     dispatch,
  #   server:  'thin',
  #   signals: false
  # )
  #
  #
  #
  # client.subscribe '/move'

  # client.on :message do |m|
  #   `say message`
  #   puts m
  # end
  #
  # client.on :open do |event|
  #   p [:open]
  #   client.send('Hello, world!')
  # end

# end
