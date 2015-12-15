class RemoveQuestionAndAnswerColumnsFromEventsAndApplications < ActiveRecord::Migration
  def change
  	remove_column :events, :question_1
  	remove_column :events, :question_2
  	remove_column :events, :question_3

  	remove_column :applications, :answer_1
  	remove_column :applications, :answer_2
  	remove_column :applications, :answer_3
  end
end
