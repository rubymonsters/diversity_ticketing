class AddColumnToApplications < ActiveRecord::Migration
  def change
    add_reference :applications, :event, index: true, foreign_key: true
  end
end
