class User < ActiveRecord::Base
  include Clearance::User

  has_many :events, foreign_key: :organizer_id, dependent: :nullify
end
