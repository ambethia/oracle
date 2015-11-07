require 'faye'
bayeux = Faye::RackAdapter.new(:mount => '/socket', :timeout => 25)
run bayeux
