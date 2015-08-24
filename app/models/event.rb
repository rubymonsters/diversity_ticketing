class Event < ActiveRecord::Base
  has_many :applications
  validates :organizer_name, :organizer_email, :description, :name, :question_1, presence: true
  validates :start_date, date: true
  validates :end_date, date: { after: :start_date }
  validates :organizer_email, confirmation: true
  validates :organizer_email_confirmation, presence: true
end
