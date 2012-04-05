module Fuzzzy
  module Server
    class HTTP < Grape::API
      default_format :json
      version 'v1'

      helpers do
        include Index

        def default_context
          {
            :index_name => params[:index_name],
            :query => params[:query]
          }
        end
      end

      namespace :info do
        http_basic do |u, p| 
          u == 'admin' && p == 'password'
        end

        get do
          info = {
            'ruby' => RUBY_VERSION,
            'environment' => Fuzzzy.env,
            'redis' => Fuzzzy.redis.client.id,
            'root_dir' => Fuzzzy.root
          }
          if params[:show_config]
            info['config'] = ZmqJobs.config
            info['stopwords'] = ZmqJobs.stopwords
          end
          info
        end

        get 'indexes' do
          indexes_info = {
            :redis_size => Fuzzzy.redis.info['used_memory_human'],
            :index => Fuzzzy.redis.hgetall(Fuzzzy::Redis.counter_key)
          }
        end
      end

      namespace :search do
        # /search/city:name/ngram?query=Bankok&distance=2&sort_by=distance
        # /search/user:fullname/soundex?query=Maria%20Huana
        get '/:index_name/:index_type/' do
          context = default_context
          [:distance, :sort_by].each do |key|
            context[key] = params[key] if params[key]
          end
          
          _searcher.search(context)
        end
      end
    end
  end
end
