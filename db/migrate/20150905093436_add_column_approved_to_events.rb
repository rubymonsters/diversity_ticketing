class AddColumnApprovedToEvents < ActiveRecord::Migration[5.1]
  def change
    change_table :events do |t|
      t.boolean :approved, default: false, null: false
    end
  end
end
