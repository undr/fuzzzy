$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
ENV['RACK_ENV'] = 'test'
require "rspec"
require 'mongoid'
require 'fuzzzy'
require Fuzzzy.root.join('spec', 'models', 'city')
require Fuzzzy.root.join('spec', 'models', 'indexed_city')

Fuzzzy.redis = Redis.new(:host => 'localhost', :database => 10)
Fuzzzy.logger = Mongoid.logger = nil
Mongoid.load!(Fuzzzy.root.join('spec', 'config', 'mongoid.yml'))

RSpec.configure do |config|
  config.mock_with :rspec
  config.after :suite do
    Mongoid.master.collections.select{|c| c.name !~ /system/ }.each(&:drop)
    keys = Fuzzzy.redis.keys("*")
    if keys.length > 1
      Fuzzzy.redis.del(*keys)
    end
  end
end
