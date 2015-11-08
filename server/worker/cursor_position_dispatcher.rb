require_relative '../backend/mouse_move_handler'

class CursorPositionDispatcher
  def self.current_cursor_positions(redis)
    @redis.keys("#{MouseMoveHandler::MOUSE_MOVE_NAMESPACE}*").callback do |keys|
      @redis.mget(*keys).callback do |values|
        yield CursorResponse.new(Hash[keys.zip values])
      end
    end
  end

  def initialize(redis, websocket)
    @redis = redis
    @websocket = websocket
  end

  def dispatch!
    self.class.current_cursor_positions(@redis) do |cursor_response|
      return if cursor_response.empty?

      @redis.set('last-tick-letter', cursor_response.agreed_upon_letter)
    end
  end

  private

end

class CursorResponse
  def initialize(key_value_pairs)
    @letters = key_value_pairs.values
  end

  def empty?
    @letters.length.zero?
  end

  def agreed_upon_letter
    @letters.detect { |e| @letters.count(e) > 1 }
  end
end
