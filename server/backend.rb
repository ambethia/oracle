require 'faye/websocket'
require 'redis'
require_relative "backend/message_dispatcher"

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
        MessageDispatcher.new(redis, ws.object_id, clients, event.data).dispatch!
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
