module Fuzzzy
  module Ngram
    class Base
      include Redis

      attr_reader :context

      def with_context context
        @context = context and yield if context
      rescue => e
        raise e
      ensure
        @context = nil
      end

      def index_key index, ngram_key
        [
          shared_key,
          'ngram_i',
          ngram_key,
          index
        ].join(':')
      end

      def dictionary_key id
        [
          shared_key,
          'dictionary',
          id
        ].join(':')
      end

      def model_name
        context[:model_name]
      end
      
      def ngrams string=nil
        string ||= query_index_string
        string.downcase!
        context[string] ||= (0..string.length-3).to_a.collect{|idx| string[idx,3] }
      end
    end
  end
end
