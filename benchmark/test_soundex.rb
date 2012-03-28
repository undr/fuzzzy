$LOAD_PATH.unshift File.expand_path("../../benchmark", __FILE__)
require File.expand_path('../../lib/fuzzzy', __FILE__)
require 'fuzzzy_benchmark'

puts 'Without stripping stopwords'
FuzzzyBenchmark.process(:soundex, [{
  :query => 'eastleigh naersouthempton',
  :distance => 4
}, {
  :query => 'alixandropolis',
  :distance => 2
}, {
  :query => 'jenan',
  :distance => 1
}])

puts 'With stripping stopwords'
FuzzzyBenchmark.process(:soundex, [{
  :query => 'eastleigh naersouthempton',
  :distance => 4,
  :strip_stopwords => true
}, {
  :query => 'alixandropolis',
  :distance => 2,
  :strip_stopwords => true
}, {
  :query => 'jenan',
  :distance => 1,
  :strip_stopwords => true
}], {:strip_stopwords => true})
