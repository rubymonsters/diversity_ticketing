class Application < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates :name, :attendee_info_1, :attendee_info_2, presence: true
  validates :email, presence: true, confirmation: true, format: { with: /.+@.+\..+/ }
  validates :email_confirmation, presence: true
  validates :terms_and_conditions, acceptance: true, allow_nil: false

  def different_data
  end
end
