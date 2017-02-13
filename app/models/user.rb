class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :events, foreign_key: :organizer_id, dependent: :nullify

  def self.admin
  	where(admin: true)
  end
end
