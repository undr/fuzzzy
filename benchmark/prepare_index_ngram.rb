require 'csv'

result = []
indexer = Fuzzzy::Ngram::Indexer.new
context = {
  :field => :name,
  :model_name => 'city',
  :method => :ngram
}

CSV.foreach(Fuzzzy.root.join('benchmark', 'data', 'cities.csv').to_s,
  :headers => true, :encoding => 'utf-8'
) do |row|
  result << row.to_hash.symbolize_keys
end


puts "Create index:"
puts "#{result.size} names"
start = Time.now
result.each do |source|
  indexer.create_index(context.merge(
    :dictionary_string => source[:name].downcase,
    :id => source[:id]
  ))
end

puts "#{Time.now - start} sec."
puts "size - #{Fuzzzy.redis.info['used_memory_human']}"