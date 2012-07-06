$LOAD_PATH.unshift File.expand_path("../..", __FILE__)
require './lib/fuzzzy'
require 'grape'

Fuzzzy.redis = Redis.new(
  :host => (ENV['REDIS_HOST'] || 'localhost'),
  :port => (ENV['REDIS_PORT'] || 6379),
  :database => (ENV['REDIS_DB'] || 0)
)

run Fuzzzy::Server::HTTP
