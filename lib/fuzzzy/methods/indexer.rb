module Fuzzzy
  module Indexer
    def delete_dictionary id
      redis.del(dictionary_key(id))
      redis.hincrby(counter_key, index_name, -1)
    end

    def save_dictionary id, string
      redis.set(dictionary_key(id), query_index_string)
      redis.hincrby(counter_key, index_name, 1)
    end
  end
end
