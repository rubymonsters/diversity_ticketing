class AddDeletedColumnToEventsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :deleted, :boolean, default: false
  end
end
