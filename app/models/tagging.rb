class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :event
  belongs_to :user
end
