module Fuzzzy
  module Ngram
    class Base < MethodBase
      def ngrams string=nil
        string ||= query_index_string
        return [string] if string.size < 3
        context[string] ||= (0..string.length-3).map{|idx| string[idx,3] }
      end
      
      def index_type
        'ngram_i'
      end
    end
  end
end
