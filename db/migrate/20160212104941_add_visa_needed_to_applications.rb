class AddVisaNeededToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :visa_needed, :boolean, null: false, default: false
  end
end
