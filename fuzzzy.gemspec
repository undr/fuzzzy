# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fuzzzy/version"

Gem::Specification.new do |s|
  s.name        = "fuzzzy"
  s.version     = Fuzzzy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Undr"]
  s.email       = ["undr@yandex.ru"]
  s.homepage    = "http://github.com/undr/fuzzzy"
  s.summary     = %q{Fuzzy Search client and server}
  s.description = %q{Fuzzy Search client and server}

  s.rubyforge_project = "fuzzzy"
  
  s.add_development_dependency "rspec", ">= 2"
  s.add_development_dependency "yard", "~> 0.6.0"
  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "bson_ext"
  s.add_development_dependency "mongoid"
  s.add_development_dependency "pry"
  s.add_development_dependency 'ruby-prof'
  
  s.add_dependency "bundler"
  s.add_dependency "rake"
  s.add_dependency "activesupport"
  s.add_dependency "eventmachine"
  s.add_dependency "yajl-ruby"
  s.add_dependency "levenshtein-ffi"
  s.add_dependency "text"
  s.add_dependency "hiredis"
  s.add_dependency "redis"
  s.add_dependency "daemons"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
