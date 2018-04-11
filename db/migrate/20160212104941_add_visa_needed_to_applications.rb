class AddVisaNeededToApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :applications, :visa_needed, :boolean, null: false, default: false
  end
end
