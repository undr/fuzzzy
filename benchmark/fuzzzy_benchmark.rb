require 'csv'
require 'benchmark'
require 'ruby-prof'

module FuzzzyBenchmark
  extend Fuzzzy::Index

  module_function
  def benchmark meth, contexts, index_cntx={}, times=100, &block
    @search_method = meth
    @times = times
    prepare_indexes(default_context.merge(index_cntx))

    Benchmark.bm do |benchmark|
      contexts.each do |context|
        report(benchmark, context.merge(index_cntx))
      end

      yield(benchmark, self) if block_given?
    end

  ensure
    Fuzzzy.redis.flushdb
    @search_method = nil
  end

  def profile meth, context, index_cntx={}, times=100, &block
    @search_method = meth
    @times = times
    prepare_indexes(default_context.merge(index_cntx))

    RubyProf.start

    @times.times do
      searcher.search(context)
    end

    result = RubyProf.stop

    flat_printer = RubyProf::FlatPrinter.new(result)
    callstack_printer = RubyProf::CallStackPrinter.new(result)
    graph_printer = RubyProf::GraphHtmlPrinter.new(result)

    File.open(Fuzzzy.root.join('benchmark', 'reports', "#{search_method}_graph.html"), 'w') do |file| 
      graph_printer.print(file)
    end
    File.open(Fuzzzy.root.join('benchmark', 'reports', "#{search_method}_callstack.html"), 'w') do |file| 
      callstack_printer.print(file)
    end
    File.open(Fuzzzy.root.join('benchmark', 'reports', "#{search_method}_flat.txt"), 'w') do |file| 
      flat_printer.print(file)
    end
  ensure
    Fuzzzy.redis.flushdb
    @search_method = nil
  end

  def report bench, context
    context = default_context.merge(context)
    result, strings = get_result(context)

    puts "Execute #{@times} times"
    puts "query: '#{context[:query]}', result: '#{result}' => #{strings}"
    bench.report(context[:title] || '') do
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

  def prepare_indexes cntx
    puts "Create index for #{search_method}:"
    puts "#{fixtures.size} names"

    start = Time.now
    fixtures.each do |source|
      indexer.create_index(cntx.merge(
        :dictionary_string => source[:name].downcase,
        :id => source[:id]
      ))
    end

    puts "#{Time.now - start} sec."
    puts "size - #{Fuzzzy.redis.info['used_memory_human']}"
  end

  def default_context
    {
      :index_name => 'city:name',
      :method => search_method
    }
  end

  def indexer
    _indexer(search_method)
  end

  def searcher
    _searcher(search_method)
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

  def search_method
    @search_method
  end

  def search_method= meth
    @search_method = meth
  end
end
