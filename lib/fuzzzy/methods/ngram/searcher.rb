module Fuzzzy
  module Ngram
    class Searcher < Base
      def search cntx
        with_context(cntx) do
          if ids = redis.sunion(*index_keys)
            ids.each do |id|
              string = redis.get(dictionary_key(id))
              dist = Levenshtein.distance(query_index_string, string)
              result << {
                :id => id,
                :distance => dist,
                :alpha => string
              } if dist <= distance
            end
            result.sort_by!{|item|item[sort_by]} if sort_by
            result.map{|item|item[:id]}
          else
            []
          end
        end
      end

      def index_keys
        keys = []
        ngrams.each_with_index do |ngram, index|
          segment_points(index) do |i|
            keys << index_key(i, ngram)
          end
        end
        keys
      end

      def segment_points index
        right = crop_length(index) >= distance ? (distance + index) : (ngrams.size - 1)
        left = index > distance ? (index - distance) : 0
        (left..right).each do |i|
          yield i
        end
      end

      def crop_length index
        ngrams.size - (index + 1)
      end

      def distance
        context[:distance] ||= 0
      end

      def result
        context[:result] ||= []
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
