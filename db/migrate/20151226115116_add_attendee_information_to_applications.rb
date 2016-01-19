class AddAttendeeInformationToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :attendee_info_1, :text
    add_column :applications, :attendee_info_2, :text
  end
end
