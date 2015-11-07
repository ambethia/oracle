require 'rubygems'
require 'bundler/setup'

require_relative 'server/app'

$stdout.sync = true
run App
