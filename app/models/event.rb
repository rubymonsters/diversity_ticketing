class Event < ActiveRecord::Base
  has_many :applications
  
  validates :organizer_name, :description, :name, presence: true
  validates :start_date, date: true
  validates :end_date, date: { after: :start_date }
  validates :organizer_email, confirmation: true, format: { with: /.+@.+\..+/ }, presence: true
  validates :organizer_email_confirmation, presence: true, on: :create

  def self.approved
    where(approved: true)
  end

  def to_csv
    CSV.generate do |csv|
    	csv << ["name", "email", question_1, question_2, question_3]
      applications.each do |application|
        csv << [application.name, application.email, application.answer_1, application.answer_2, application.answer_3]
      end
    end
  end
end
