$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
ENV['RACK_ENV'] = 'test'
require "rspec"
require 'mongoid'
require 'fuzzzy'
require Fuzzzy.root.join('spec', 'models', 'city')
require Fuzzzy.root.join('spec', 'models', 'indexed_city')

Fuzzzy.redis = Redis.new(:host => 'localhost', :database => 10)
Fuzzzy.logger = nil
Mongoid.load!(Fuzzzy.root.join('spec', 'config', 'mongoid.yml'))

RSpec.configure do |config|
  config.mock_with :rspec
end
