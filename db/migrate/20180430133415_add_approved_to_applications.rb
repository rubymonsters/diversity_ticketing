class AddApprovedToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :approved, :boolean
  end
end
