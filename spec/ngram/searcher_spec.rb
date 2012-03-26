require 'spec_helper'

describe Fuzzzy::Soundex::Searcher do
  let(:indexer){Fuzzzy::Ngram::Indexer.new}
  let(:index_context){{
    :field => :name,
    :model_name => 'city',
    :method => :ngram
  }}
  let(:searcher){Fuzzzy::Ngram::Searcher.new}
  let(:context){index_context.merge(:query => query_string, :distance => 1)}
  
  before do
    keys = Fuzzzy.redis.keys("*")
    Fuzzzy.redis.del(*keys) if keys.length > 0
  end
  
  describe '#segment_points' do
    context 'when distance = 0' do
      let(:result){[]}
      let(:sample){[
        [0],  # mos
        [1],  # osk
        [2],  # sko
        [3],  # kow
      ]}
      before do
        searcher.with_context(:distance => 0, :query => 'moscow') do
          searcher.segment_points(index) do |i|
            result << i
          end
        end
      end
    
      (0...4).each do |idx|
        context "and index = #{idx}" do
          let(:index){idx}
          specify{result.should == sample[index]}
        end
      end
    end
    
    context 'when distance = 1' do
      let(:result){[]}
      let(:sample){[
        [0, 1],     # mos
        [0, 1, 2],  # osk
        [1, 2, 3],  # sko
        [2, 3],     # kow
      ]}
      before do
        searcher.with_context(:distance => 1, :query => 'moscow') do
          searcher.segment_points(index) do |i|
            result << i
          end
        end
      end
    
      (0...4).each do |idx|
        context "and index = #{idx}" do
          let(:index){idx}
          specify{result.should == sample[index]}
        end
      end
    end
    
    context 'when distance = 3' do
      let(:result){[]}
      let(:sample){[
        [0, 1, 2, 3],  # mos
        [0, 1, 2, 3],  # osk
        [0, 1, 2, 3],  # sko
        [0, 1, 2, 3]   # kow
      ]}
      before do
        searcher.with_context(:distance => 3, :query => 'moscow') do
          searcher.segment_points(index) do |i|
            result << i
          end
        end
      end
    
      (0...4).each do |idx|
        context "and index = #{idx}" do
          let(:index){idx}
          specify{result.should == sample[index]}
        end
      end
    end
    
    context 'when distance = 3 and long word' do
      let(:result){[]}
      let(:sample){[
        [0, 1, 2, 3],           # lev
        [0, 1, 2, 3, 4],        # eve
        [0, 1, 2, 3, 4, 5],     # ven
        [0, 1, 2, 3, 4, 5, 6],  # ens
        [1, 2, 3, 4, 5, 6, 7],  # nsh
        [2, 3, 4, 5, 6, 7, 8],  # sht
        [3, 4, 5, 6, 7, 8],     # hte
        [4, 5, 6, 7, 8],        # tei
        [5, 6, 7, 8]            # ein
      ]}
      before do
        searcher.with_context(:distance => 3, :query => 'levenshtein') do
          searcher.segment_points(index) do |i|
            result << i
          end
        end
      end
    
      (0...9).each do |idx|
        context "and index = #{idx}" do
          let(:index){idx}
          specify{result.should == sample[index]}
        end
      end
    end
  end
  
  describe '#index_keys' do
    let(:query_string){'mascow'}
    specify do
      searcher.with_context(context) do
        searcher.index_keys.should =~ [
          searcher.index_key(0, 'mas'),
          searcher.index_key(1, 'mas'),
          searcher.index_key(0, 'asc'),
          searcher.index_key(1, 'asc'),
          searcher.index_key(2, 'asc'),
          searcher.index_key(1, 'sco'),
          searcher.index_key(2, 'sco'),
          searcher.index_key(3, 'sco'),
          searcher.index_key(2, 'cow'),
          searcher.index_key(3, 'cow')
        ]
      end
    end
  end
  
  describe '#search' do
    context 'single word - #1' do
      before do
        indexer.create_index(index_context.merge(
          :dictionary_string => dictionary_string,
          :id => id
        ))
      end
      
      let(:query_string){'mascow'}
      let(:dictionary_string){'moscow'}
      let(:id){'12345'}
      
      specify{searcher.search(context).should == [id]}
    end
    
    context 'single word - #2' do
      before do
        indexer.create_index(index_context.merge(
          :dictionary_string => dictionary_string,
          :id => id
        ))
      end
      
      let(:query_string){'jenergija'}
      let(:dictionary_string){'energiya'}
      let(:id){'12345'}
      
      specify{searcher.search(context.merge(
        :distance => 2
      )).should == [id]}
    end
    
    context 'many words' do
    end
  end
end
