require 'faye'

use Faye::RackAdapter, mount: '/socket', timeout: 25

public_files = Dir.entries('public')[2..-1] - ['index.html']
use Rack::Static, urls: public_files, root: 'public', index: 'index.html'

run lambda { |_env|
  [ 404, { 'Content-Type' => 'text/plain' }, '404 Not Found' ]
}
