class User < ApplicationRecord
  include Clearance::User

  has_many :events, foreign_key: :organizer_id, dependent: :nullify
  has_many :applications, foreign_key: :applicant_id
  has_many :taggings
  has_many :tags, through: :taggings, foreign_key: :user_id

  attr_accessor :new_password
  attr_accessor :password_optional

  validates :privacy_policy_agreement, acceptance: true, on: :create

  def self.admin
  	where(admin: true)
  end

  def self.created_last_30_days
    where('created_at > ?', 31.days.ago)
  end

  def password_optional?
    password_optional
  end
end
