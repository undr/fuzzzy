require 'spec_helper'

describe Fuzzzy::Ngram::Indexer do
  let(:indexer){Fuzzzy::Ngram::Indexer.new}
  let(:context){{
    :index_name => 'city:name',
    :method => :ngram,
    :dictionary_string => dictionary_string,
    :id => id
  }}
  let(:dictionary_string){'moscow'}
  let(:id){'12345'}
  let(:counter_key){Fuzzzy::Redis.counter_key}
  
  before do
    keys = Fuzzzy.redis.keys("*")
    Fuzzzy.redis.del(*keys) if keys.length > 0
  end
  
  describe '#ngrams' do
    specify do
      indexer.with_context(context) do
        indexer.ngrams('mo').should == ['mo']
      end
    end
    specify do
      indexer.with_context(context) do
        indexer.ngrams('mos').should == ['mos']
      end
    end
    specify do
      indexer.with_context(context) do
        indexer.ngrams.should == ['mos', 'osc', 'sco', 'cow']
      end
    end
  end
  
  describe '#create_index' do
    let(:keys){Fuzzzy.redis.keys}
    let(:dictionary_keys){["fuzzzy:city:name:dictionary:#{id}"]}
    
    before do
      indexer.create_index(context)
    end
    
    specify{keys.size.should == 6}
    specify do
      keys.should =~ [
        'fuzzzy:city:name:ngram_i:mos:0',
        'fuzzzy:city:name:ngram_i:osc:1',
        'fuzzzy:city:name:ngram_i:sco:2',
        'fuzzzy:city:name:ngram_i:cow:3',
      ] + dictionary_keys + [counter_key]
    end
    specify do
      Fuzzzy.redis.mget(*dictionary_keys).should == ['moscow']
    end
    specify do
      Fuzzzy.redis.sunion(*(keys - dictionary_keys - [counter_key])).should == [id]
    end
    specify{Fuzzzy.redis.hgetall(counter_key).should == {'city:name' => '1'}}
    
    context 'with empty string' do
      let(:dictionary_string){''}
      
      specify{keys.size.should == 0}
    end
    
    context 'with nulled string' do
      let(:dictionary_string){nil}
      
      specify{keys.size.should == 0}
    end
    
    context 'with multiple calls' do
      let(:another_id){'11111'}
      let(:dictionary_keys){[
        "fuzzzy:city:name:dictionary:#{id}",
        "fuzzzy:city:name:dictionary:#{another_id}"
      ]}
      
      before do
        indexer.create_index(context.merge(
          :dictionary_string => 'Mostyn',
          :id => another_id
        ))
      end
      
      specify{keys.size.should == 10}
      specify do
        keys.should =~ [
          'fuzzzy:city:name:ngram_i:mos:0',
          'fuzzzy:city:name:ngram_i:osc:1',
          'fuzzzy:city:name:ngram_i:sco:2',
          'fuzzzy:city:name:ngram_i:cow:3',
          'fuzzzy:city:name:ngram_i:ost:1',
          'fuzzzy:city:name:ngram_i:sty:2',
          'fuzzzy:city:name:ngram_i:tyn:3',
        ] + dictionary_keys + [counter_key]
      end
      specify do
        Fuzzzy.redis.mget(*dictionary_keys).should == [dictionary_string, 'mostyn']
      end
      specify do
        Fuzzzy.redis.sunion(*(keys - dictionary_keys - [counter_key])).should =~ [id, another_id]
      end
      specify{Fuzzzy.redis.hgetall(counter_key).should == {'city:name' => '2'}}
    end
  end
  
  describe '#delete_index' do
    let(:keys){Fuzzzy.redis.keys}
    let(:another_id){'11111'}
    let(:dictionary_keys){["fuzzzy:city:name:dictionary:#{another_id}"]}
    
    before do
      indexer.create_index(context)
      indexer.create_index(context.merge(
        :dictionary_string => 'Mostyn',
        :id => another_id
      ))
      indexer.delete_index(context)
    end
    
    specify{keys.size.should == 6}
    specify do
      keys.should =~ [
        'fuzzzy:city:name:ngram_i:mos:0',
        'fuzzzy:city:name:ngram_i:ost:1',
        'fuzzzy:city:name:ngram_i:sty:2',
        'fuzzzy:city:name:ngram_i:tyn:3',
      ] + dictionary_keys + [counter_key]
    end
    specify do
      Fuzzzy.redis.mget(*dictionary_keys).should == ['mostyn']
    end
    specify do
      Fuzzzy.redis.sunion(*(keys - dictionary_keys - [counter_key])).should =~ [another_id]
    end
    specify{Fuzzzy.redis.hgetall(counter_key).should == {'city:name' => '1'}}
  end
end
