require 'spec_helper'

describe Fuzzzy::Soundex::Indexer do
  let(:indexer){Fuzzzy::Soundex::Indexer.new}
  let(:context){{
    :index_name => 'city:name',
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
    specify{Fuzzzy.redis.hgetall(Fuzzzy::Redis.counter_key).should == {'city:name' => '1'}}
  end
  
  describe '.delete_index' do
    before do
      indexer.create_index(context)
      indexer.delete_index(context)
    end
    
    specify{Fuzzzy.redis.exists('fuzzzy:city:name:soundex_i:' + soundex).should be_false}
    specify{Fuzzzy.redis.exists('fuzzzy:city:name:dictionary:' + id).should be_false}
    specify{Fuzzzy.redis.hgetall(Fuzzzy::Redis.counter_key).should == {'city:name' => '0'}}
  end
end
