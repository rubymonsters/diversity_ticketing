class User < ApplicationRecord
  include Clearance::User

  has_many :events, foreign_key: :organizer_id, dependent: :nullify
  has_many :applications, foreign_key: :applicant_id

  def self.admin
  	where(admin: true)
  end

  def self.created_last_30_days
    where('created_at > ?', 31.days.ago)
  end
end
