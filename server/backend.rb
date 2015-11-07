require 'faye/websocket'
require 'redis'

# redis = Redis.new(driver: :synchrony)
module Server
  # Message handling
  class Backend
    KEEPALIVE_TIME = 15

    attr_reader :clients, :redis

    def initialize(app)
      @app     = app
      @clients = []
      @redis   = EM::Hiredis.connect
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        pass_to_faye(env)
      else
        pass_to_sinatra(env)
      end
    end

    private

    def pass_to_sinatra(env)
      @app.call(env)
    end

    def pass_to_faye(env)
      ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)
      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        p [:message, event.data]
        MessageParser.new(event.data, clients, ws, redis).dispatch!
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response
    end
  end
end

class MessageParser
  MOUSE_MOVE_PATTERN = /^move:/

  def initialize(message, clients, websocket, redis)
    @message = message
    @clients = clients
    @websocket = websocket
    @redis = redis
  end

  def dispatch!
    if is_mouse_move?
      MouseMove.new(@message, @redis, @websocket.object_id).store!
    else
      dispatch_message_to_clients!
    end
  end

  def dispatch_message_to_clients!
    @clients.each { |client| client.send(@message) }
  end

  private

  def is_mouse_move?
    @message =~ MOUSE_MOVE_PATTERN
  end
end

class MouseMove
  def initialize(message, redis, client_id)
    @redis = redis
    @event, @x, @y, @mouseup = message.split(':')
    @client_id = client_id
  end

  def store!
    @redis.set("mousemove:#{@client_id}", "#{@x},#{@y}")
    @redis.set("mouseup:#{@client_id}", @mouseup)
  end
end
