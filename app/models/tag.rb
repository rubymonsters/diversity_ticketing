class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :events, through: :taggings
end
