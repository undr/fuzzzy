require 'rubygems'
require 'bundler'
Bundler.require :default, (ENV['RACK_ENV'] || 'development')
require 'yaml'
require 'logger'
require 'active_support'
require 'yajl'
require 'levenshtein-ffi'
require 'text'
require 'redis/connection/hiredis'
require 'redis'

module Fuzzzy
  extend self
  extend ActiveSupport::Autoload

  autoload :Redis
  autoload :MethodBase, 'fuzzzy/methods/method_base'

  module Soundex
    extend ActiveSupport::Autoload

    autoload :Base, 'fuzzzy/methods/soundex/base'
    autoload :Indexer, 'fuzzzy/methods/soundex/indexer'
    autoload :Searcher, 'fuzzzy/methods/soundex/searcher'
  end
  
  module Ngram
    extend ActiveSupport::Autoload

    autoload :Base, 'fuzzzy/methods/ngram/base'
    autoload :Indexer, 'fuzzzy/methods/ngram/indexer'
    autoload :Searcher, 'fuzzzy/methods/ngram/searcher'
  end

  if defined?(Mongoid)
    module Mongoid
      extend ActiveSupport::Autoload

      autoload :Index, 'fuzzzy/orm/mongoid/index'
    end
  end

  def logger
    @logger = default_logger unless defined?(@logger)
    @logger
  end

  def logger=(logger)
    case logger
      when Logger then @logger = logger
      when false, nil then @logger = nil
    end
  end

  def redis
    @redis ||= ::Redis.new(
      :host => 'localhost',
      :port => 6379,
      :database => 0
    )
  end
  
  def redis= connection
    @redis = connection
  end
  
  def stopwords
    @stopwords ||= default_stopwords
  end
  
  def stopwords= value
    @stopwords = load_stopwords(value).uniq
  end
  
  def load_stopwords options
    if options.is_a?(Hash)
      stops = load_stopwords(options[:stopwords])
      options[:default] ? (stops + default_stopwords) : stops
    elsif options.is_a?(Array)
      options
    elsif options.is_a?(String) || options.is_a?(Pathname)
      YAML.load_file(options)
    else
      []
    end
  end
  
  def default_stopwords
    @default_stopwords ||= load_stopwords(Fuzzzy.root.join('dictionary', 'en_stopwords.yml').to_s)
  end

  def env
    return Rails.env if defined?(Rails)
    return Sinatra::Base.environment.to_s if defined?(Sinatra)
    ENV["RACK_ENV"] || 'development'
  end

  def root
    @root ||= Pathname.new(File.expand_path('.'))
  end

  protected
  def default_logger
    defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : ::Logger.new($stdout)
  end
end
