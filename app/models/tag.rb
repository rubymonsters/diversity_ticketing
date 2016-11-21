class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :events, through: :taggings
  belongs_to :category
end
