class Event < ActiveRecord::Base
  has_many :applications
  
  validates :organizer_name, :description, :name, :question_1, presence: true
  validates :start_date, date: true
  validates :end_date, date: { after: :start_date }
  validates :organizer_email, confirmation: true, format: { with: /.+@.+\..+/ }, presence: true
  validates :organizer_email_confirmation, presence: true, on: :create

  def self.approved
    where(approved: true)
  end
end
