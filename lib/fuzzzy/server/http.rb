require 'pp'
module Fuzzzy
  module Server
    class HTTP < Grape::API
      class ParamsError < StandardError
      end

      format :json
      default_format :json
      error_format :json
      version 'v1', :using => :path

      rescue_from :all do |e|
        rack_response({:error => e.class.name, :message => e.message}.to_json)
      end

      helpers do
        include Index
        
        def search
          context = search_context
          check_context!(:query, context)
          _searcher(context[:index_method]).search(context)
        end
        
        def check_context! *keys
          context = keys.pop
          ([:index_name, :index_method] + keys).each do |key|
            raise ParamsError.new("Parameter :#{key} not found") if context[key].nil?
          end
        end
        
        def assign_context! *keys
          context = {}
          ([:index_name, :index_method] + keys).each do |key|
            context[key] = params[key] if params[key]
          end
          context
        end
        
        def index_context *keys
          assign_context!(:id, :dictionary_string)
        end
        
        def search_context
          assign_context!(:query, :distance, :sort_by)
        end
      end

      namespace :info do
        http_basic do |u, p| 
          u == 'admin' && p == 'password'
        end

        get do
          info = {
            :ruby => RUBY_VERSION,
            :environment => Fuzzzy.env,
            :redis => Fuzzzy.redis.client.id,
            :root_dir => Fuzzzy.root.to_s
          }
          info[:stopwords] = Fuzzzy.stopwords if params[:show_stopwords]
          info
        end

        get 'indexes' do
          indexes_info = {
            :redis_size => Fuzzzy.redis.info['used_memory_human'],
            :index => Fuzzzy.redis.hgetall(Fuzzzy::Redis.counter_key)
          }
        end
      end
      
      resource :indexes do
        # curl  /v1/indexes?index_name=city:name&index_method=ngram&query=search%20string
        get do
          search
        end
        
        post '/search' do
          search
        end
        
        post do
          context = index_context
          check_context!(:id, :dictionary_string, context)
          _indexer(context[:index_method]).create_index(context)
        end
        
        delete do
          context = index_context
          check_context!(:id, context)
          _indexer(context[:index_method]).delete_index(context)
        end
      end
    end
  end
end
