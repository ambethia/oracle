$stdout.sync = true

require 'rubygems'
require 'bundler/setup'

require_relative 'server/app'

# Faye::WebSocket.load_adapter('thin')

use Faye::RackAdapter, mount: '/bayeux', timeout: 25
run App
