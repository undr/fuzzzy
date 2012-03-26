module Fuzzzy
  module Soundex
    class Searcher < Base
      def search context
        with_context(context) do
          if ids = redis.smembers(index_key(soundex))
            result = ids.map do |id|
              string = redis.get(dictionary_key(id))
              {
                :id => id,
                :distance => Levenshtein.distance(query_index_string, string),
                :alpha => string
              }
            end

            result.sort_by!{|item|item[sort_by]} if sort_by
            result.reject!{|item|item[:distance] > context[:distance]} if context[:distance]
            result.map{|item|item[:id]}
          else
            []
          end
        end
      end

      def sort_by
        context[:sort_by]
      end

      def query_index_string
        context[:query]
      end
    end
  end
end
