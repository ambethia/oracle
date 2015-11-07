$stdout.sync = true

require 'faye/websocket'

require_relative 'server/app'
require_relative 'server/backend'

Faye::WebSocket.load_adapter('thin')

use Server::Backend
run Server::App
