module Fuzzzy
  module Ngram
    class Base < MethodBase
      def ngrams string=nil
        string ||= query_index_string
        return [string] if string.size < 3
        context[string] ||= (0..string.length-3).to_a.collect{|idx| string[idx,3] }
      end
      
      def type
        :ngram
      end
    end
  end
end
