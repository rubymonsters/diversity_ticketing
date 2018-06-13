class AddDeletedColumnToApplicationsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :deleted, :boolean, default: false
  end
end
