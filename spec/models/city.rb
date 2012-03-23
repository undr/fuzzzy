class City
  include Mongoid::Document
  include Fuzzzy::Mongoid::Index

  field :name, :type => String
  field :country, :type => String

end
