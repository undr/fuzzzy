$LOAD_PATH.unshift File.expand_path("../../benchmark", __FILE__)
require File.expand_path('../../lib/fuzzzy', __FILE__)
require 'prepare_index_soundex'
require 'benchmark'

searcher = Fuzzzy::Soundex::Searcher.new
context = {
  :field => :name,
  :model_name => 'city',
  :method => :soundex
}

result1 = searcher.search(context.merge(
  :query => 'eastleigh naersouthempton',
  :distance => 4
))
strings1 = result1.map{|id|Fuzzzy.redis.get('fuzzzy:city:name:dictionary:' + id)}

result2 = searcher.search(context.merge(
  :query => 'alixandropolis',
  :distance => 2
))
strings2 = result2.map{|id|Fuzzzy.redis.get('fuzzzy:city:name:dictionary:' + id)}

result3 = searcher.search(context.merge(
  :query => 'jenan',
  :distance => 1
))
strings3 = result3.map{|id|Fuzzzy.redis.get('fuzzzy:city:name:dictionary:' + id)}

Benchmark.bm do |b|
  puts "query: 'eastleigh naersouthempton', result: '#{result1}' => #{strings1}"
  b.report('search very long word') do
    100.times do
      searcher.search(context.merge(
        :query => 'eastleigh naersouthempton',
        :distance => 4
      ))
    end
  end
  
  puts "query: 'alixandropolis', result: '#{result2}' => #{strings2}"
  b.report('search long word') do
    100.times do
      searcher.search(context.merge(
        :query => 'alixandropolis',
        :distance => 2
      ))
    end
  end
  
  puts "query: 'jenan', result: '#{result3}' => #{strings3}"
  b.report('search short word') do
    100.times do
      searcher.search(context.merge(
        :query => 'jenan',
        :distance => 1
      ))
    end
  end
end

Fuzzzy.redis.flushdb