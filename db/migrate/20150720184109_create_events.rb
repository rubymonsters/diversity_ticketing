class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :organizer_name
      t.string :organizer_email 
      t.text :description
      t.text :name 
      t.date :date
      t.text :question_1
      t.text :question_2
      t.text :question_3

      t.timestamps null: false
    end
  end
end
