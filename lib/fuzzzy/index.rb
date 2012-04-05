module Fuzzzy
  module Index
    def _indexer method
      @indexer ||= {}
      @indexer[method] ||= class_for(:indexer, method).new
    end

    def _searcher method
      @searcher ||= {}
      @searcher[method] ||= class_for(:searcher, method).new
    end

    def class_for type, method
      "fuzzzy/#{method}/#{type}".classify.constantize
    end
  end
end
