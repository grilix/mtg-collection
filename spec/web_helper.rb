require_relative 'support/web'

require 'rack/test'
require './http'

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Support::Web)
end
