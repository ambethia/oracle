class MouseMoveHandler
  MOUSE_MOVE_NAMESPACE = "move:"
  MOUSE_MOVE_PATTERN = /^#{MOUSE_MOVE_NAMESPACE}/

  def self.should_handle?(message)
    !!(message =~ MOUSE_MOVE_PATTERN)
  end

  def initialize(redis, client_id, message)
    @redis = redis
    @client_id = client_id
    @event, @letter = message.split(':')
  end

  def handle!
    @redis.set("#{MOUSE_MOVE_NAMESPACE}#{@client_id}", @letter)
  end
end
