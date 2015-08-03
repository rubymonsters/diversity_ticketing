class ChangeDateColumnInEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.rename :date, :start_date
      t.date :end_date
    end 
  end
end
