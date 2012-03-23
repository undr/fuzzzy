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
                :alpha => sort_metric(string)
              }
            end

            result.sort_by!{|item|item[sort_method]} if sort_method
            result.reject!{|item|item[:distance] >= context[:distance]} if context[:distance]
            result.map{|item|item[:id]}
          end
        end
      end

      def sort_method
        context[:sort_method]
      end

      def query_index_string
        context[:query]
      end

      def model_name
        context[:model_name].downcase
      end
    end
  end
end
