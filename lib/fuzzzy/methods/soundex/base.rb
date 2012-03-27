module Fuzzzy
  module Soundex
    class Base < MethodBase
      def soundex string=nil
        context[:soundex] ||= Text::Soundex.soundex(string || query_index_string)
      end

      def type
        :soundex
      end
    end
  end
end
