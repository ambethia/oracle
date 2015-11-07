require 'faye'

use Faye::RackAdapter, mount: '/socket', timeout: 25
use Rack::Static, urls: [''], root: 'public', index: 'index.html'

run lambda { |_env|
  puts "lambda"
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}
