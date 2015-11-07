require 'faye'
require 'redis'

require_relative 'mouse_move_handler'

EM.run do
  redis = Redis.new(:driver => :synchrony)
  websocket = Faye::Client.new('http://localhost:9292/socket')

  websocket.subscribe('/move') do |message|
    puts message.inspect
    MouseMoveHandler.handle!(message: message, redis: redis)
  end
end
