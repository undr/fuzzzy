$LOAD_PATH.unshift File.expand_path("../../benchmark", __FILE__)
require File.expand_path('../../lib/fuzzzy', __FILE__)
require 'fuzzzy_benchmark'

FuzzzyBenchmark.process(:ngram, [{
  :query => 'eastleigh naersouthempton',
  :distance => 4
}, {
  :query => 'alixandropolis',
  :distance => 2
}, {
  :query => 'jenan',
  :distance => 1
}])
