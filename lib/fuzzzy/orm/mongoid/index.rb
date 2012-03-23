module Fuzzzy
  module Mongoid
    module Index
      extend ActiveSupport::Concern

      included do
        class_attribute :fuzzzy_indexes
        around_save :create_fuzzzy_indexes
        around_update :create_fuzzzy_indexes
        around_destroy :delete_fuzzzy_indexes
      end

      module ClassMethods 
        def define_fuzzzy_index field, options={}
          options[:field] = field.to_sym
          self.fuzzzy_indexes ||= {}
          self.fuzzzy_indexes[field.to_sym] = default_options.merge(options)
        end

        def has_fuzzzy_indexes?
          !!self.fuzzzy_indexes
        end

        def default_options
          {
            :method => :soundex,
            :only_ids => false,
            :model_name => self.name.downcase
          }
        end

        def indexer method
          return nil unless has_fuzzzy_indexes?
          @indexer ||= {}
          @indexer[method] ||= class_for(:indexer, method).new
        end

        def searcher method
          return nil unless has_fuzzzy_indexes?
          @searcher ||= {}
          @searcher[method] ||= class_for(:searcher, method).new
        end

        def class_for type, method
          "fuzzzy/#{method}/#{type}".classify.constantize
        end

        def search_by field, query, context={}
          index_context = self.fuzzzy_indexes[field.to_sym]
          raise "You have not fuzzy index for '#{field}' field" unless index_context
          
          index_context[:query] = query
          index_context.merge!(context)
          ids = searcher(index_context[:method]).search(index_context)

          (index_context[:only_ids] ? ids : self.find(ids)) if ids
        end
      end

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
        self.class.indexer(options[:method]).send(command, options.merge(
          :id => self.id,
          :dictionary_string => self.send(field)
        ))
      end
    end
  end
end
