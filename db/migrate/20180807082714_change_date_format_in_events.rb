class ChangeDateFormatInEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :deadline, :datetime
  end
end
