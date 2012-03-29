module Fuzzzy
  module Ngram
    class Indexer < Base
      def query_index_string
        context[:prepared_dictionary_string] ||= prepare_string(context[:dictionary_string])
      end

      def create_index cntx
        with_context(cntx) do
          return if query_index_string.empty?

          delete_index

          ngrams.each_with_index do |ngram, index|
            redis.sadd(index_key(ngram, index), context[:id])
          end

          redis.set(dictionary_key(context[:id]), query_index_string)
        end
      end

      def delete_index cntx=nil
        block = lambda do
          if older_string = redis.get(dictionary_key(context[:id]))
            ngrams(older_string).each_with_index do |ngram, index|
              redis.srem(index_key(ngram, index), context[:id])
            end

            redis.del(dictionary_key(context[:id]))
          end
        end
        cntx ? with_context(cntx, &block) : block.call
      end
    end
  end
end
