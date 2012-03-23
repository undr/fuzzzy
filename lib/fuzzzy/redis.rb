module Fuzzzy
  module Redis
    def redis
      Fuzzzy.redis
    end

    def shared_key
      [
        'fuzzzy',
        model_name,
        context[:field]
      ].join(':')
    end
  end
end
