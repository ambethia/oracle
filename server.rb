require 'faye'
require 'redis'

require_relative 'server/mouse_move_handler'

EM.run {
  redis = Redis.new(:driver => :synchrony)
  websocket = Faye::Client.new('http://localhost:9292/socket')

  websocket.subscribe('/move') do |message|
    MouseMoveHandler.handle!(message: message, redis: redis)
  end

  EM.add_periodic_timer(1) do
    GameCompletionHandler.new(redis: redis, websocket: websocket).detect_completion_and_start_over!
  end


  EM.add_periodic_timer(0.01) do
    websocket.publish('/move', 'x' => 25, 'y' => 39, 'client' => 'F00BAR')
  end
}
