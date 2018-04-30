class AddSubmittedToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :submitted, :boolean
  end
end
