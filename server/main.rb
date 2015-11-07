$stdout.sync = true

require 'faye/websocket'
require 'redis'

require_relative 'mouse_move_handler'

HOST = 'localhost:5000' # TODO: Fix


puts "1"

EM.run do
  puts "2"
  # redis = Redis.new(driver: :synchrony)
  # ws = Faye::WebSocket::Client.new("ws://#{HOST}/bayeux")
  #
  # ws.on :open do |event|
  #   p [:open, event]
  # end
  #
  # ws.on :message do |event|
  #   p [:message, event]
  # end
  #
  # ws.on :close do |event|
  #   p [:close, event.code, event.reason]
  # end

  ws = Faye::WebSocket::Client.new("ws://#{HOST}/bayeux")

  puts ws.inspect

  ws.send('hello') do |message|
    puts message
  end

  ws.on('open') do |e|
    puts [:open, e]
  end

  ws.on('message') do |event|
    puts event.inspect
    MouseMoveHandler.handle!(message: message, redis: redis)
  end
end
