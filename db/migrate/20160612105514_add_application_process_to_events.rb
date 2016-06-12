class AddApplicationProcessToEvents < ActiveRecord::Migration
  def change
    add_column :events, :application_by_organizer, :boolean, default: false, null: false
  end
end
