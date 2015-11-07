require 'em-hiredis'
require 'faye/websocket'

class Worker
  def initialize
    EM.add_periodic_timer(1) {
      CursorPositionDispatcher.new(redis, websocket).dispatch!
    }
  end

  def redis
    @redis ||= EM::Hiredis.connect
  end

  def websocket
    @websocket ||= Faye::WebSocket::Client.new("ws://localhost:#{ENV['PORT']}/bayeux")
  end
end

class CursorPositionDispatcher
  def initialize(redis, websocket)
    @redis = redis
    @websocket = websocket
  end

  def dispatch!
    @redis.keys('mousemove:*').callback { |keys|
      @redis.mget(*keys).callback { |values|
        @websocket.send("position:#{position values}")
      }
    }
  end

  def position(values)
    coordinates = values.map { |value| value.split(',') }
    x_coordinate = average(coordinates, :first)
    y_coordinate = average(coordinates, :last)
    "#{x_coordinate}:#{y_coordinate}"
  end

  def average(collection, method_sym)
    return 0 if collection.length == 0
    collection = collection.map(&method_sym)
    collection.map(&:to_i).inject(0, :+) / collection.length
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
    @websocket.send('move:x:y:mouseup')
  end
end
