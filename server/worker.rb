require 'em-hiredis'
require 'faye/websocket'

class Worker
  def initialize
    GameTick.reset_game_state!(redis)

    EM.add_periodic_timer(0.5) {
      GameTick.new(websocket, redis).tick!
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
  RESET_COORDINATES = "0:0"

  def initialize(redis, websocket)
    @redis = redis
    @websocket = websocket
  end

  def dispatch!
    @redis.keys('mousemove:*').callback { |keys|
      @redis.mget(*keys).callback { |values|
        current_position = position(values)

        @redis.mset *keys.zip([RESET_COORDINATES] * keys.length).flatten

        unless current_position == RESET_COORDINATES
          @websocket.send("position:#{position values}")
        end
      }
    }
  end

  def position(values)
    coordinates = values.delete_if { |pair| pair == RESET_COORDINATES }.map { |value| value.split(':') }
    return RESET_COORDINATES if coordinates.length.zero?
    x_coordinate = average(coordinates, :first)
    y_coordinate = average(coordinates, :last)
    "#{x_coordinate}:#{y_coordinate}"
  end

  def average(collection, method_sym)
    collection.lazy.map(&method_sym).map(&:to_i).inject(0, :+) / collection.length
  end
end


# Basic Game Loop Logic:
#
# when_letter_is_selected do
#   detect_letter_from_cursor_position! do |letter|
#     if letter =! END_OF_LINE
#       start_new_letter
#     else
#       end_round
#       expire_mousemove_keys
#       prepare_new_round
#       begin_new_round
#     end
#   end
# end

class GameTick
  STATES = %w(questions)

  def self.reset_game_state!(redis)
    redis.set('game-state', STATES.first)
    redis.ltrim('questions', 0, -1)
  end

  def initialize(websocket, redis)
    @websocket = websocket
    @redis = redis
  end

  def tick!
    # @websocket.send("move:#{rand(10)}:#{rand(8)}:mouseup")
  end
end
