module Fuzzzy
  module Soundex
    class Indexer < Base
      include Fuzzzy::Indexer
      def query_index_string
        context[:prepared_dictionary_string] ||= prepare_string(context[:dictionary_string])
      end

      def create_index cntx
        with_context(cntx) do
          return if query_index_string.empty?

          delete_index
          redis.sadd(index_key(soundex), context[:id])
          save_dictionary(context[:id], query_index_string)
        end
      end

      def delete_index cntx=nil
        block = lambda do
          if older_string = redis.get(dictionary_key(context[:id]))
            redis.srem(index_key(soundex(older_string)), context[:id])
            delete_dictionary(context[:id])
          end
        end
        cntx ? with_context(cntx, &block) : block.call
      end
    end
  end
end
