module Fuzzzy
  class MethodBase
    include Redis

    attr_reader :context

    def with_context cntx
      @context = cntx.dup and yield if cntx
    rescue => e
      raise e
    ensure
      @context = nil
    end

    def model_name
      context[:model_name]
    end
    
    def prepare_string string
      str = string.dup.downcase
      str = context[:filter].call(str) if context[:filter] && context[:filter].respond_to?(:call)
      str = (str.split - stopwords).join(' ') if context[:strip_stopwords]
      str
    end
    
    def stopwords
      return context[:strip_stopwords] if context[:strip_stopwords] && context[:strip_stopwords].is_a?(Array) 
      Fuzzzy.stopwords
    end
  end
end
