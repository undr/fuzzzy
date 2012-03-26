require 'csv'
require 'benchmark'
module FuzzzyBenchmark
  module_function
  def process type, contexts, times=1000, &block
    @type = type
    @times = times
    prepare_indexes
    
    Benchmark.bm do |benchmark|
      contexts.each do |context|
        report(benchmark, context)
      end
    
      yield(benchmark, self) if block_given?
    end
    
  ensure
    Fuzzzy.redis.flushdb
    @type = nil
  end
  
  def report benchmark, context
    result, strings = get_result(default_context.merge(context))

    puts "Execute #{@times} times"
    puts "query: '#{context[:query]}', result: '#{result}' => #{strings}"
    benchmark.report(context[:title] || '') do
      @times.times do
        searcher.search(context)
      end
    end
    puts ''
  end
  
  def get_result cntx
    result = searcher.search(cntx)
    strings = result.map{|id|Fuzzzy.redis.get('fuzzzy:city:name:dictionary:' + id)}
    [result, strings]
  end

  def prepare_indexes
    puts "Create index for #{type}:"
    puts "#{fixtures.size} names"

    start = Time.now
    fixtures.each do |source|
      indexer.create_index(default_context.merge(
        :dictionary_string => source[:name].downcase,
        :id => source[:id]
      ))
    end

    puts "#{Time.now - start} sec."
    puts "size - #{Fuzzzy.redis.info['used_memory_human']}"
  end

  def default_context
    {
      :field => :name,
      :model_name => 'city',
      :method => type
    }
  end

  def class_for klass
    "fuzzzy/#{type}/#{klass}".classify.constantize
  end

  def indexer
    @indexer ||= {}
    @indexer[type] ||= class_for(:indexer).new
  end

  def searcher
    @searcher ||= {}
    @searcher[type] ||= class_for(:searcher).new
  end

  def fixtures
    @fixtures ||= begin
      result = []
      CSV.foreach(Fuzzzy.root.join('benchmark', 'data', 'cities.csv').to_s,
        :headers => true, :encoding => 'utf-8'
      ) do |row|
        result << row.to_hash.symbolize_keys
      end
      result
    end
  end
  
  def type
    @type
  end
end
