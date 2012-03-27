module Fuzzzy
  module Ngram
    class Base < MethodBase
      def ngrams string=nil
        string ||= query_index_string
        string.downcase!
        context[string] ||= (0..string.length-3).to_a.collect{|idx| string[idx,3] }
      end
      
      def type
        :ngram
      end
    end
  end
end
