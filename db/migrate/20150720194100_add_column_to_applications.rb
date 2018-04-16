class AddColumnToApplications < ActiveRecord::Migration[5.1]
  def change
    add_reference :applications, :event, index: true, foreign_key: true
  end
end
