module Fuzzzy
  module Soundex
    class Indexer < Base
      def query_index_string
        context[:dictionary_string]
      end

      def create_index context
        with_context(context) do
          delete_index
          redis.sadd(index_key(soundex), context[:id])
          redis.set(dictionary_key(context[:id]), query_index_string)
        end
      end

      def delete_index ctx=nil
        block = lambda do
          if older_string = redis.get(dictionary_key(context[:id]))
            redis.srem(index_key(soundex(older_string)), context[:id])
            redis.del(dictionary_key(context[:id]))
          end
        end
        ctx ? with_context(ctx, &block) : block.call
      end
    end
  end
end
