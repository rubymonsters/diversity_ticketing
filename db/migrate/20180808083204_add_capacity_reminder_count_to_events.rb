class AddCapacityReminderCountToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :capacity_reminder_count, :integer, default: 0
  end
end
