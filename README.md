# Fuzzzy

The fuzzy search with redis-stored indexes.

[![Build Status](https://secure.travis-ci.org/undr/fuzzzy.png?branch=master)](http://travis-ci.org/undr/fuzzzy)

## Install and configuration

Add to Gemfile:

    gem 'fuzzzy'

and run `bundle install`

Configuration is very simple:

    Fuzzzy.configure do |config|
      config.logger = Logger.new($stdout)
      config.redis = Redis.new(
        :host => 'localhost',
        :port => 6379,
        :database => 0
      )
      config.stopwords = %w{the stopwords list}
    end

Put this code in initializers folder if you use rails or at the beginning of the application otherwise.

## Usage

There are several ways to use:

- **As standalone module.** 

- **As MongoId module.** 

- **As HTTP server.** 

### As standalone module

    class CitySearch
      include Fuzzzy::Index
      
      def search context
        _searcher.search(context)
      end
      
      def create_index context
        _indexer.create_index(context)
      end
      
      def delete_index context
        _indexer.delete_index(context)
      end
    end
    
    s = CitySearch.new
    s.create_index(
      :method => :ngram,
      :index_name => 'city',
      :dictionary_string => 'Moscow',
      :id => '1'
    )
    s.create_index(
      :method => :ngram,
      :index_name => 'city',
      :dictionary_string => 'Rom',
      :id => '2'
    )
    
    result = s.search({
      :method => :ngram,
      :index_name => 'city',
      :query => 'Moskow',
      :distance => 1
    })
    
    puts result # 1

### As MongoId module

    class City
      include Mongoid::Document
      include Fuzzzy::Mongoid::Index
    
      field :name, :type => String
      
      define_fuzzzy_index :name, :method => :ngram
    end
    
    City.create(:name => 'Moscow')
    City.create(:name => 'Rom')
    
    pp City.search(:query => 'Moskow', :distance => 1)

### As HTTP server

