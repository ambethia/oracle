require_relative 'mouse_move_handler'

class MessageDispatcher
  def initialize(redis, client_id, websocket_clients, message)
    @redis = redis
    @client_id = client_id
    @websocket_clients = websocket_clients
    @message = message
  end

  def dispatch!
    if MouseMoveHandler.should_handle?(@message)
      MouseMoveHandler.new(@redis, @client_id, @message).handle!
    else
      dispatch_message_to_clients!
    end
  end

  private

  def dispatch_message_to_clients!
    @websocket_clients.each do |client|
      client.send(@message)
    end
  end
end
