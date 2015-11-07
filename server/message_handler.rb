class MessageHandler
  attr_reader :message
  attr_reader :redis

  def self.handle!(*args)
    new(*args).handle!
  end

  def initialize(message:, redis:)
    @message = message
    @redis = redis
  end

  def handle!
    raise 'You must implement a handle! method'
  end

  def client_id
    message.fetch('client_id')
  end
end
