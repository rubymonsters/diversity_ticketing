class Event < ActiveRecord::Base
  include ApplicationProcess::Validator
  belongs_to :organizer, class_name: 'User'

  has_many :applications, dependent: :destroy

  validates :organizer_name, :description, :name, :website, :code_of_conduct, :city, :country, presence: true
  validates :start_date, :deadline, date: true, presence: true
  validates :end_date, date: { after_or_equal_to: :start_date }, presence: true
  validates :organizer_email, confirmation: true, format: { with: /.+@.+\..+/ }, presence: true
  validates :organizer_email_confirmation, presence: true, on: :create
  validates :website, :code_of_conduct, format: { with: /(http|https):\/\/.+\..+/ }
  validates :number_of_tickets, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, presence: true
  validates :twitter_handle, format: { with: /\A@?\w+\z/ }, allow_nil: true

  def self.approved
    where(approved: true)
  end

  def self.unapproved
    where(approved: false)
  end

  def self.upcoming(now = DateTime.now)
    where('end_date >= ?', now)
  end

  def self.past(now = DateTime.now)
    where('end_date < ?', now)
  end

  def self.open(now = DateTime.now)
    where('deadline >= ?', now)
  end

  def self.closed(now = DateTime.now)
    where('deadline < ?', now)
  end

  def self.deadline_in_two_days(now = DateTime.now)
    where('deadline = ?', now + 2.days)
  end

  def open?
    deadline_as_time >= Time.now
  end

  def closed?
    deadline_as_time < Time.now
  end

  def deadline_as_time
    (deadline + 1).in_time_zone("UTC")
  end

  def location
    [city, state_province, country].reject(&:blank?).join(", ")
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["Name", "Email", "Why do you want to attend #{self.name} and what especially do you look forward to learning?", "Please share with us why you're applying for a diversity ticket."]
      applications.each do |application|
        csv << [application.name, application.email, application.attendee_info_1, application.attendee_info_2]
      end
    end
  end

  def twitter_handle=(value)
    super(value.blank? ? nil : value.sub(/\A@/, ''))
  end
end
