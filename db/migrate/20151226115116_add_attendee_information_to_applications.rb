class AddAttendeeInformationToApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :applications, :attendee_info_1, :text
    add_column :applications, :attendee_info_2, :text
  end
end
