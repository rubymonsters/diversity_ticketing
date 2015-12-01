class Event < ActiveRecord::Base
  has_many :applications, dependent: :destroy

  validates :organizer_name, :description, :name, :website, :code_of_conduct, :city, :country, presence: true
  validates :start_date, :deadline, date: true
  validates :end_date, date: { after_or_equal_to: :start_date }
  validates :organizer_email, confirmation: true, format: { with: /.+@.+\..+/ }, presence: true
  validates :organizer_email_confirmation, presence: true, on: :create
  validates :website, :code_of_conduct, format: { with: /.+\..+/}
  validates :number_of_tickets, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def self.approved
    where(approved: true)
  end

  def self.dispproved
    where(approved: false)
  end

  def self.upcoming
    where('end_date > ?', DateTime.now)
  end

  def self.past
    where('end_date < ?', DateTime.now)
  end

  def open?
    end_date > DateTime.now
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
