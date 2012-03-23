module Fuzzzy
  module Mongoid
    module Index
      include ActiveSupport::Concern

      included do
        class_attribute :fuzzzy_indexes
        around_save :create_fuzzzy_indexes
        around_update :create_fuzzzy_indexes
        around_remove :delete_fuzzzy_indexes
      end

      module ClassMethods 
        def define_fuzzzy_index field, options={}
          self.fuzzzy_indexes ||= {}
          self.fuzzzy_indexes[field.to_sym] = default_options.merge(options)
        end

        def default_options
          {
            :method => :soundex,
            :only_ids => false
          }
        end

        def indexer method
          @indexer ||= {}
          @indexer[method] ||= class_for(:indexer, method).new
        end

        def searcher method
          @searcher ||= {}
          @searcher[method] ||= class_for(:searcher, method).new
        end

        def class_for type, method
          "#{method}/#{type}".classify.constantize
        end

        def search_by field, query, options={}
          options = self.fuzzzy_indexes[field.to_sym]
          raise "You have not fuzzy index for '#{field}' field" unless options
          ids = searcher(options[:method]).search({
            :query => query,
            :field => field.to_sym,
            :model_name => self.name.downcase
          }.merge(options))

          (options[:only_ids] ? self.find(ids) : ids) if ids
        end
      end

      module InstanceMethods
        def delete_fuzzzy_indexes &block
          change_indexes(:delete_index, &block)
        end

        def create_fuzzzy_indexes &block
          change_indexes(:create_index, &block)
        end

        def change_indexes command, condition=nil
          Fuzzzy.redis.multi
          self.class.fuzzzy_indexes.each do |(field, opts)|
            change_field_index(command, field, opts) if command == :delete_index ||
              self.changed.includes?(field.to_s)
          end
          yield
          Fuzzzy.redis.exec
        rescue
          Fuzzzy.redis.discard
        end

        def change_field_index command, field, options
          self.class.indexer(options[:method]).send(command, options.merge(:model => self, :field => field))
        end
      end
    end
  end
end
