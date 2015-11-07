class GameLoop
  attr_reader :redis
  attr_reader :websocket

  def initialize(redis:, websocket:)
    @redis = redis
    @websocket = websocket
  end

  def tick!
    when_letter_is_selected do
      delete_mouse_handler_keys!
      # detect_letter_from_cursor_position! do |letter|
      #   if letter =! END_OF_LINE
      #     start_new_letter
      #   else
      #     end_round
      #     prepare_new_round
      #     begin_new_round
      #   end
      # end
    end
  end

  private

  def when_letter_is_selected
    redis.get("#{MouseMoveHandler::MOUSEUP_NAMESPACE}:*").callback do |rows|
      yield if letter_is_selected?(rows)
    end
  end

  def detect_letter_from_cursor_position!(&block)
  end

  def letter_is_selected?(records)
    records.select { |record| record == 'true' }.length > records.length
  end

  def begin_new_game!
    websocket.publish('/done')

    EM.add_timer(5) {
      websocket.publish('/prepare')
    }

    EM.add_timer(10) {
      websocket.publish('/begin')
    }
  end

  def delete_mouse_handler_keys!
    MouseMoveHandler.cleanup_redis!
  end
end
