require 'eventmachine'
require 'sinatra/base'
require 'faye'
require 'redis'
require 'thin'

require_relative 'mouse_move_handler'

Faye::WebSocket.load_adapter('thin')

$stdout.sync = true

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

EM.run do
  dispatch = Rack::Builder.app do
    use Faye::RackAdapter, mount: '/bayeux', timeout: 25
    map '/' do
      run App.new
    end
  end

  redis = Redis.new(driver: :synchrony)
  Rack::Server.start(
    Port:    ENV['PORT'],
    app:     dispatch,
    server:  'thin',
    signals: false
  )

  client = Faye::WebSocket::Client.new("ws://localhost:#{ENV['PORT']}/bayeux")

  client.on :open do |event|
    p [:open]
    client.send('Hello, world!')
  end

  client.onmessage = lambda do |m|
    `say open`
    puts m
  end
end
