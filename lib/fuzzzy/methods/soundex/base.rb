module Fuzzzy
  module Soundex
    class Base < MethodBase
      def soundex string=nil
        context[:soundex] ||= Text::Soundex.soundex(string || query_index_string)
      end

      def index_type
        'soundex_i'
      end
    end
  end
end
