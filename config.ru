ENV['PORT'] ||= '3000'

$stdout.sync = true

require 'faye/websocket'

require_relative 'server/app'
require_relative 'server/backend'
require_relative 'server/worker'

Faye::WebSocket.load_adapter('thin')

Signal.trap("INT")  { EventMachine.stop }
Signal.trap("TERM") { EventMachine.stop }

EM.run {
  Worker.new

  Thin::Server.start('localhost', ENV['PORT'], signals: false) do
    use Server::Backend
    run Server::App
  end
}

