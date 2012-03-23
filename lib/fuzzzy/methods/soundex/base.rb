module Fuzzzy
  module Soundex
    class Base
      include Redis

      attr_reader :context

      def with_context context
        @context = context and yield if context
      ensure
        @context = nil
      end

      def soundex string=nil
        context[:soundex] ||= Text::Soundex.soundex(string || query_index_string)
      end

      def index_key soundex_key
        [
          shared_key,
          'soundex_index',
          soundex_key
        ].join(':')
      end

      def dictionary_key id
        [
          shared_key,
          'dictionary',
          id
        ].join(':')
      end
    end
  end
end
