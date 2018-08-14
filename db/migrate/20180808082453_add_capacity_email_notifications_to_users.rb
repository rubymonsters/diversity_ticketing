class AddCapacityEmailNotificationsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :capacity_email_notifications, :string, default: "OFF"
  end
end
