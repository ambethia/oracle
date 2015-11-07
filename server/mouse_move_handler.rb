require_relative 'message_handler'

# Mouse Movement
class MouseMoveHandler < MessageHandler
  POSITION_NAMESPACE = 'position'
  MOUSEUP_NAMESPACE = 'position'

  def self.cleanup_redis!
    redis.del(
      redis.keys(
        "#{POSITION_NAMESPACE}:*",
        "#{MOUSEUP_NAMESPACE}:*"
      )
    )
  end

  def handle!
    Fiber.new do
      redis.set("#{POSITION_NAMESPACE}:#{client_id}", position)
      redis.set("#{MOUSEUP_NAMESPACE}:#{client_id}", mouse_up?)
    end
  end

  private

  def mouse_up?
    message.fetch('mouseup', true)
  end

  def position
    "#{x},#{y}"
  end

  def x
    message.fetch('x', 0).to_i
  end

  def y
    message.fetch('y', 0).to_i
  end
end
