class AddOrganizerIdToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :organizer, index: true
    add_foreign_key :events, :users, column: :organizer_id
  end
end
