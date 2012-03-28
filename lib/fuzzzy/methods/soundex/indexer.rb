module Fuzzzy
  module Soundex
    class Indexer < Base
      def query_index_string
        context[:prepared_dictionary_string] ||= prepare_string(context[:dictionary_string])
      end

      def create_index cntx
        with_context(cntx) do
          delete_index
          redis.sadd(index_key(soundex), context[:id])
          redis.set(dictionary_key(context[:id]), query_index_string)
        end
      end

      def delete_index cntx=nil
        block = lambda do
          if older_string = redis.get(dictionary_key(context[:id]))
            redis.srem(index_key(soundex(older_string)), context[:id])
            redis.del(dictionary_key(context[:id]))
          end
        end
        cntx ? with_context(cntx, &block) : block.call
      end
    end
  end
end
