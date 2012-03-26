require 'spec_helper'

describe Fuzzzy::Ngram::Indexer do
  let(:indexer){Fuzzzy::Ngram::Indexer.new}
  let(:context){{
    :field => :name,
    :model_name => 'city',
    :method => :ngram,
    :dictionary_string => dictionary_string,
    :id => id
  }}
  let(:dictionary_string){'moscow'}
  let(:id){'12345'}
  
  before do
    keys = Fuzzzy.redis.keys("*")
    Fuzzzy.redis.del(*keys) if keys.length > 0
  end
  
  describe '#ngrams' do
    specify do
      indexer.with_context(context) do
        indexer.ngrams('Moscow').should == ['mos', 'osc', 'sco', 'cow']
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
    
    specify{keys.size.should == 5}
    specify do
      keys.should =~ [
        'fuzzzy:city:name:ngram_i:mos:0',
        'fuzzzy:city:name:ngram_i:osc:1',
        'fuzzzy:city:name:ngram_i:sco:2',
        'fuzzzy:city:name:ngram_i:cow:3',
      ] + dictionary_keys
    end
    specify do
      Fuzzzy.redis.mget(*dictionary_keys).should == ['moscow']
    end
    specify do
      Fuzzzy.redis.sunion(*(keys - dictionary_keys)).should == [id]
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
      
      specify{keys.size.should == 9}
      specify do
        keys.should =~ [
          'fuzzzy:city:name:ngram_i:mos:0',
          'fuzzzy:city:name:ngram_i:osc:1',
          'fuzzzy:city:name:ngram_i:sco:2',
          'fuzzzy:city:name:ngram_i:cow:3',
          'fuzzzy:city:name:ngram_i:ost:1',
          'fuzzzy:city:name:ngram_i:sty:2',
          'fuzzzy:city:name:ngram_i:tyn:3',
        ] + dictionary_keys
      end
      specify do
        Fuzzzy.redis.mget(*dictionary_keys).should == [dictionary_string, 'mostyn']
      end
      specify do
        Fuzzzy.redis.sunion(*(keys - dictionary_keys)).should =~ [id, another_id]
      end
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
    
    specify{keys.size.should == 5}
    specify do
      keys.should =~ [
        'fuzzzy:city:name:ngram_i:mos:0',
        'fuzzzy:city:name:ngram_i:ost:1',
        'fuzzzy:city:name:ngram_i:sty:2',
        'fuzzzy:city:name:ngram_i:tyn:3',
      ] + dictionary_keys
    end
    specify do
      Fuzzzy.redis.mget(*dictionary_keys).should == ['mostyn']
    end
    specify do
      Fuzzzy.redis.sunion(*(keys - dictionary_keys)).should =~ [another_id]
    end
  end
end
