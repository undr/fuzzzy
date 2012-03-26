require 'spec_helper'

describe Fuzzzy::Soundex::Indexer do
  let(:indexer){Fuzzzy::Soundex::Indexer.new}
  let(:context){{
    :field => :name,
    :model_name => 'city',
    :method => :soundex,
    :dictionary_string => dictionary_string,
    :id => id
  }}
  let(:dictionary_string){'moscow'}
  let(:soundex){Text::Soundex.soundex(dictionary_string)}
  let(:id){'12345'}
  
  before do
    keys = Fuzzzy.redis.keys("*")
    Fuzzzy.redis.del(*keys) if keys.length > 1
  end
  
  describe '.create_index' do
    before do
      indexer.create_index(context)
    end
    
    specify{Fuzzzy.redis.smembers('fuzzzy:city:name:soundex_i:' + soundex).should == [id]}
    specify{Fuzzzy.redis.get('fuzzzy:city:name:dictionary:' + id).should == dictionary_string}
  end
  
  describe '.delete_index' do
    before do
      Fuzzzy.redis.sadd('fuzzzy:city:name:soundex_i:' + soundex, id)
      Fuzzzy.redis.set('fuzzzy:city:name:dictionary:' + id, dictionary_string)
      indexer.delete_index(context)
    end
    
    specify{Fuzzzy.redis.exists('fuzzzy:city:name:soundex_i:' + soundex).should be_false}
    specify{Fuzzzy.redis.exists('fuzzzy:city:name:dictionary:' + id).should be_false}
  end
end
