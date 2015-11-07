$stdout.sync = true

require 'faye'
# require 'redis'

require_relative 'mouse_move_handler'

HOST = 'localhost:5000' # TODO: Fix

EM.run do
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

  ws = Faye::Client.new("ws://#{HOST}/bayeux")

  ws.publish('/woo', 'hello') do |message|
    puts message
  end

  ws.subscribe('/move') do |message|
    puts message.inspect
    MouseMoveHandler.handle!(message: message, redis: redis)
  end
end
