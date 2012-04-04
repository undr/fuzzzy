require 'spec_helper'

class TestRedis
  include Fuzzzy::Redis

  def index_type
    'index_type'
  end

  def model_name
    'model_name'
  end

  def context
    {:field => 'field'}
  end
end

class TestRedis2
  include Fuzzzy::Redis
end


describe Fuzzzy::Redis do
  subject{TestRedis.new}

  describe '#shared_key' do
    specify{subject.shared_key.should == 'fuzzzy:model_name:field'}
  end

  describe '#index_key' do
    specify{subject.index_key('key1').should == 'fuzzzy:model_name:field:index_type:key1'}
    specify{subject.index_key('key1', 'key2').should == 'fuzzzy:model_name:field:index_type:key1:key2'}
    specify{subject.index_key('key1', 2).should == 'fuzzzy:model_name:field:index_type:key1:2'}
    specify do
      lambda{
        subject.index_key
      }.should raise_error
    end
    context do
      subject{TestRedis2.new}
      specify do
        lambda{
          subject.index_key('key1')
        }.should raise_error
      end
      specify do
        lambda{
          subject.index_key('key1', 'key2')
        }.should raise_error
      end
    end
  end
end
