require 'spec_helper'

describe Fuzzzy::Mongoid::Index do
  let(:context){{
    :field => :name,
    :model_name => 'indexedcity',
    :method => :soundex,
    :only_ids => false
  }}
  
  describe '.define_fuzzzy_index' do
    context 'without index' do
      let!(:city){City}
      specify{city.fuzzzy_indexes.should be_nil}
      specify{city.has_fuzzzy_indexes?.should be_false}
    end
    
    context 'with default index' do
      let!(:city){IndexedCity}
      specify{city.fuzzzy_indexes.should be_instance_of(Hash)}
      specify{city.fuzzzy_indexes.values.should have(1).index}
      specify{city.fuzzzy_indexes[:name].should == context}
      specify{city.has_fuzzzy_indexes?.should be_true}
    end
  end
  
  describe '.indexer' do
    specify{IndexedCity.indexer(:soundex).should be_instance_of(Fuzzzy::Soundex::Indexer)}
    specify{City.indexer(:soundex).should be_nil}
    specify do
      lambda{
        IndexedCity.indexer(:blablabla)
      }.should raise_error
    end
  end

  describe '.searcher' do
    specify{IndexedCity.searcher(:soundex).should be_instance_of(Fuzzzy::Soundex::Searcher)}
    specify{City.searcher(:soundex).should be_nil}
    specify do
      lambda{
        IndexedCity.searcher(:blablabla)
      }.should raise_error
    end
  end
  
  describe '.search_by' do
    let(:query){'String'}
    
    context 'by indexed field' do
      let(:searcher){mock(:searcher)}
      
      before do
        searcher.should_receive(:search).with(index_context)
        IndexedCity.stub(:searcher => searcher)
      end
    
      context 'with default context' do
        let(:index_context){context.merge(:query => query)}
        specify{IndexedCity.search_by(:name, query)}
      end
    
      context 'with custom context' do
        let(:index_context){context.merge(
          :query => query,
          :only_ids => true,
          :sort_method => :alpha,
          :distance => 3
        )}
        
        specify{IndexedCity.search_by(:name, query, {
          :only_ids => true,
          :sort_method => :alpha,
          :distance => 3
        })}
      end
    end
    
    context 'by unindexed field' do
      specify do
        lambda{
          IndexedCity.search_by(:country, query)
        }.should raise_error
      end
    end
  end
end
