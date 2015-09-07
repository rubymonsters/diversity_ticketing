class AddColumnApprovedToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :approved, default: false, null: false
    end
  end
end
