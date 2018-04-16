class AddSelectionProcessToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :selection_by_organizer, :boolean, default: false, null: false
  end
end
