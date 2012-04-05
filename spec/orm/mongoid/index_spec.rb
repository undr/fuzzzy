require 'spec_helper'

describe Fuzzzy::Mongoid::Index do
  let(:context){{
    :index_name => 'indexedcity:name',
    :method => :soundex
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
        searcher.should_receive(:search).with(search_context)
        IndexedCity.stub(:searcher => searcher)
      end
    
      context 'with default context' do
        let(:search_context){context.merge(:query => query)}
        specify{IndexedCity.search_by(:name, query)}
      end
    
      context 'with custom context' do
        let(:search_context){context.merge(
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

  context do
    let(:model){IndexedCity.new(:id => BSON::ObjectId.new, :name => 'Moscow', :country => 'Russia')}
    let(:indexer){mock(:indexer)}
    
    describe '.create_fuzzzy_indexes' do
      context do
        let(:index_context){context.merge(
          :id => model.id,
          :dictionary_string => model.name
        )}
        
        before do
          indexer.should_receive(:create_index).with(index_context)
          IndexedCity.stub(:indexer => indexer)
        end
        
        specify{model.create_fuzzzy_indexes{}}
      end
      
      context 'with multi fields index' do
        before do
          IndexedCity.define_fuzzzy_index(:country)
          indexer.should_receive(:create_index).exactly(2).times
          IndexedCity.stub(:indexer => indexer)
        end
        
        after do
          IndexedCity.clear_fuzzzy_index(:country)
        end
        
        specify{model.create_fuzzzy_indexes{}}
      end
      
      context 'with empty changed attributes' do
        let(:index_context){context.merge(
          :id => model.id,
          :dictionary_string => model.name
        )}
        
        before do
          model.stub(:changed => [])
          indexer.should_not_receive(:create_index)
          IndexedCity.stub(:indexer => indexer)
        end
        
        specify{model.create_fuzzzy_indexes{}}
      end
    end
    
    describe '.delete_fuzzzy_indexes' do
      context do
        let(:index_context){context.merge(
          :id => model.id,
          :dictionary_string => model.name
        )}
        
        before do
          indexer.should_receive(:delete_index).with(index_context)
          IndexedCity.stub(:indexer => indexer)
        end
        
        specify{model.delete_fuzzzy_indexes{}}
      end
      
      context 'with multi fields index' do
        before do
          IndexedCity.define_fuzzzy_index(:country)
          indexer.should_receive(:delete_index).exactly(2).times
          IndexedCity.stub(:indexer => indexer)
        end
        
        after do
          IndexedCity.clear_fuzzzy_index(:country)
        end
        
        specify{model.delete_fuzzzy_indexes{}}
      end
    end
  end
end
