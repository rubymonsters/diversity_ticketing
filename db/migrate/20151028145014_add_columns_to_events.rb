class AddColumnsToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.text :website
      t.text :code_of_conduct
      t.string :city
      t.string :country
      t.date :deadline
      t.integer :number_of_tickets
      t.boolean :ticket_funded, default: false, null: false
      t.boolean :accommodation_funded, default: false, null: false
      t.boolean :travel_funded, default: false, null: false
    end
  end
end
