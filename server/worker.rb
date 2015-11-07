require 'redis'
require 'faye/websocket'

class Worker
  def initialize
    EM.add_periodic_timer(1) {
      GameTick.new(websocket, redis).tick!
    }
  end

  def redis
    @redis ||= Redis.new(:driver => :synchrony)
  end

  def websocket
    @websocket ||= Faye::WebSocket::Client.new("ws://localhost:#{ENV['PORT']}/bayeux")
  end
end


# Basic Game Loop Logic:
#
# when_letter_is_selected do
#   delete_mouse_handler_keys!
#   detect_letter_from_cursor_position! do |letter|
#     if letter =! END_OF_LINE
#       start_new_letter
#     else
#       end_round
#       prepare_new_round
#       begin_new_round
#     end
#   end
# end

class GameTick
  def initialize(websocket, redis)
    @websocket = websocket
    @redis = redis
  end

  def tick!
    @websocket.send('move:client_id:x:y:mouseup')
  end
end
