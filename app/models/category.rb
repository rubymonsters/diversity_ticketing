class Category < ActiveRecord::Base
  has_many :tags
end
