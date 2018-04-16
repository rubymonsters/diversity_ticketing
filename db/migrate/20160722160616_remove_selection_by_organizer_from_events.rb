class RemoveSelectionByOrganizerFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :selection_by_organizer, :boolean, default: false, null: false
  end
end
