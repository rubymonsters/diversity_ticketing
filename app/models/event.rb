class Event < ApplicationRecord
  include ApplicationProcess::Validator
  belongs_to :organizer, class_name: 'User'

  has_many :applications, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :tweets
  has_many :tag_taggings, through: :tags, source: 'taggings'
  has_many :interested_users, -> { distinct }, through: :tag_taggings, source: 'user'

  validates :organizer_name, :description, :name, :website, :code_of_conduct, :city, :country, presence: true, unless: :skip_validation
  validates :start_date, date: true, presence: true, unless: :skip_validation
  validates :end_date, date: { after_or_equal_to: :start_date }, presence: true, unless: :skip_validation
  validates :deadline, date: { before: :end_date }, presence: true, unless: :skip_validation
  validates :organizer_email, confirmation: true, format: { with: /.+@.+\..+/ }, presence: true, unless: :skip_validation
  validates :organizer_email_confirmation, presence: true, on: :create, unless: :skip_validation
  validates :website, :code_of_conduct, format: { with: /(http|https):\/\/.+\..+/ }, unless: :skip_validation
  validates :number_of_tickets, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, presence: true, unless: :skip_validation
  validates :twitter_handle, format: { with: /\A@?\w+\z/ }, allow_nil: true
  validates :ticket_funded, inclusion: { in: [true] }, unless: :skip_validation

  accepts_nested_attributes_for :tags

  attr_accessor :skip_validation

  def self.application_via_diversitytickets
    where.not(application_process: 'application_by_organizer')
  end

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

  def self.open(now = DateTime.current)
    where('deadline >= ?', now)
  end

  def self.closed(now = DateTime.current)
    where('deadline < ?', now)
  end

  def self.deadline_yesterday(now = DateTime.current)
    where('deadline BETWEEN ? AND ?', (now - 1.day).beginning_of_day, (now - 1.day).end_of_day)
  end

  def self.deadline_in_three_days(now = DateTime.current)
    where('deadline BETWEEN ? AND ?', (now + 3.days).beginning_of_day, (now + 3.days).end_of_day)
  end

  def self.created_current_year(now = Time.zone.now)
    where('created_at > ? AND created_at < ?', now.beginning_of_year, now.end_of_year )
  end

  def self.active
    where(deleted: false)
  end

  def self.total_organizers
    pluck(:organizer_id).uniq.count
  end

  def open?
    deadline >= Time.now
  end

  def closed?
    deadline < Time.now
  end

  def past?
    end_date < Time.now
  end

  def location
    [city, state_province, country].reject(&:blank?).join(", ")
  end

  def unapproved
    approved == false
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["Name", "Email", "Why do you want to attend #{self.name} and what especially do you look forward to learning?", "Please share with us why you're applying for a diversity ticket."]
      applications.active.submitted.each do |application|
        csv << [application.name, application.email, application.attendee_info_1, application.attendee_info_2]
      end
    end
  end

  def twitter_handle=(value)
    super(value.blank? ? nil : value.sub(/\A@/, ''))
  end

  def owned_by?(user)
    organizer_id == user.id
  end

  def editable_by?(user)
    user.admin? || (owned_by?(user) && open?)
  end

  def uneditable_by?(user)
    !editable_by?(user)
  end

  def deletable_by?(user)
    user.admin? || owned_by?(user)
  end

  def self.country_with_most_events(country_rank)
    countries = Event.all.group_by(&:country)
    @sorted_events = countries.sort_by{|country, events| events.count}
    country = @sorted_events[-country_rank].first
  end

  def self.number_of_events_per_country(country_rank)
    events_count = @sorted_events[-country_rank].last.count
  end

  def delete_application_data
    application = self.applications.first
    attributes = application.attributes.keys - ["id", "event_id", "applicant_id", "created_at", "updated_at", "submitted", "deleted"]
    columns = {deleted: true}
    attributes.each do |attr|
      if application[attr].class == TrueClass || application[attr].class == FalseClass
        columns[attr] = false
      else
        columns[attr] = nil
      end
    end
    self.applications.each do |application|
      application.skip_validation = true
      application.update_attributes(columns)
    end
  end
end
