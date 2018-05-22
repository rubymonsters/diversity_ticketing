class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.belongs_to :event, index: true
      t.timestamps null: false
    end
  end
end
