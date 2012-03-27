module Fuzzzy
  class MethodBase
    include Redis

    attr_reader :context

    def with_context cntx
      @context = cntx and yield if cntx
    rescue => e
      raise e
    ensure
      @context = nil
    end

    def model_name
      context[:model_name]
    end
  end
end
