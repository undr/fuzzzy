module Fuzzzy
  module Soundex
    class Indexer < Base
      def query_index_string
        context[:query_index_string] ||= model.send(context[:field])
      end

      def create_index context
        with_context(context) do
          delete_index
          redis.sadd(index_key(soundex), model.id)
          redis.set(dictionary_key(model.id), query_index_string)
        end
      end

      def delete_index context=nil
        block = lambda do
          if older_string = redis.get(dictionary_key(model.id))
            redis.srem(index_key(soundex(older_string), model.id))
            redis.del(dictionary_key(model.id))
          end
        end
        context ? with_context(context, &block) : block.call
      end

      def model
        context[:model]
      end

      def model_name
        model.class.name.downcase
      end
    end
  end
end
