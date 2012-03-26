require 'spec_helper'

describe Fuzzzy::Soundex::Searcher do
  let(:searcher){Fuzzzy::Soundex::Searcher.new}
  let(:context){{
    :field => :name,
    :model_name => 'city',
    :method => :soundex,
    :query => query_string
  }}
  
  before do
    keys = Fuzzzy.redis.keys("*")
    Fuzzzy.redis.del(*keys) if keys.length > 1
  end
  
  def add_index id, dictionary_string
    Fuzzzy.redis.sadd('fuzzzy:city:name:soundex_i:' + Text::Soundex.soundex(dictionary_string), id)
    Fuzzzy.redis.set('fuzzzy:city:name:dictionary:' + id, dictionary_string)
  end
  
  describe '#search' do
    context 'single word' do
      before do
        add_index(id, dictionary_string)
      end
      
      let(:query_string){'mascow'}
      let(:dictionary_string){'moscow'}
      let(:id){'12345'}
      
      specify{searcher.search(context).should == [id]}
    end
    
    context 'many words' do
      before do
        add_index('12345', 'moscow')
        add_index('12346', 'piterburger')
        add_index('12347', 'piterberg')
        add_index('12348', 'piterburg')
        add_index('12349', 'pitsburg')
        add_index('12350', 'moscowcity')
      end
      
      let(:query_string){'mascow'}
      
      specify{searcher.search(context).should == ['12345']}
      specify{searcher.search(context.merge(:query => 'mascw')).should == ['12345']}
      specify{searcher.search(context.merge(:query => 'peterberg')).should == ['12346', '12347', '12348']}
      specify{searcher.search(context.merge(
        :query => 'piterburg',
        :sort_by => :distance
      )).should == ['12348', '12347', '12346']}
      specify{searcher.search(context.merge(
        :query => 'piterburg',
        :sort_by => :alpha
      )).should == ['12347', '12348', '12346']}
      specify{searcher.search(context.merge(
        :query => 'piterburg',
        :distance => 0
      )).should == ['12348']}
    end
  end
end
