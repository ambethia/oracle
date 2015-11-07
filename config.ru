require 'faye'

use Faye::RackAdapter, mount: '/socket', timeout: 25

use Rack::Static, urls: [''], root: 'public', index: 'index.html'

run lambda { |_env|
  [200, { 'Content-Type' => 'text/plain' }, 'OK']
}
