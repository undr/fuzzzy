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

    def index_key *args
      ([
        shared_key,
        "#{type}_i"
      ] + args).join(':')
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
