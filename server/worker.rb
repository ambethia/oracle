require 'em-hiredis'
require 'faye/websocket'

class Worker
  def initialize
    EM.add_periodic_timer(0.5) {
      CursorPositionDispatcher.new(redis, websocket).dispatch!
    }

    EM.add_periodic_timer(3) {
      GameTick.new(websocket, redis).tick!
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

  def initialize(websocket, redis)
    @websocket = websocket
    @redis = redis
  end

  def tick!
    with_mousemove_records do |keys, values|
      LetterSelectDeterminer.new(values).if_letter_is_selected? do |letter|
        LetterSelector.new(@websocket, @redis).pick_letter!(letter)
        @redis.send("letter-selected:#{letter}")
      end
    end
  end

  private

  def with_mousemove_records
    @redis.keys('mousemove:*').callback { |keys|
      @redis.mget(*keys).callback { |values|
        yield(keys, values)
      }
    }
  end
end

class LetterSelector
  def initialize(websocket, redis)
    @websocket = websocket
    @redis = redis
  end

  def pick_letter!(letter)
    @websocket.send("letter-picked:#{letter}")
    @redis.append("current-word", letter)
  end
end

class LetterSelectDeterminer
  def initialize(values)
    @values = values
  end

  def if_letter_is_selected?
    false
  end

  def if_letter_exists?
    yield(selected_letter) if should_pick_letter?
  end

  def should_pick_letter?
    inactive_values.count > (values.count / 2)
  end

  def inactive_values
    values.select { |value| value == CursorPositionDispatcher::RESET_COORDINATES }
  end
end
