class Application < ActiveRecord::Base
  belongs_to :event
  validates :name, presence: true
  validates :email, presence: true, confirmation: true, format: { with: /.+@.+\..+/ }
  validates :email_confirmation, presence: true
  validate :presence_of_questions

  def presence_of_questions
    if event.question_1.present? && answer_1.blank?
      errors.add(:answer_1, "can`t be blank")
    end
    if event.question_2.present? && answer_2.blank?
      errors.add(:answer_2, "can`t be blank")
    end
    if event.question_3.present? && answer_3.blank?
      errors.add(:answer_3, "can`t be blank")
    end
  end

end
