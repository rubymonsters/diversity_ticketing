class Application < ActiveRecord::Base
  belongs_to :event
  validates :name, presence: true
  validates :email, presence: true, confirmation: true, format: { with: /.+@.+\..+/ }
  validates :email_confirmation, presence: true

end
