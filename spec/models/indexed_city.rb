class IndexedCity
  include Mongoid::Document
  include Fuzzzy::Mongoid::Index

  field :name, :type => String
  field :country, :type => String

  define_fuzzzy_index :name
end
