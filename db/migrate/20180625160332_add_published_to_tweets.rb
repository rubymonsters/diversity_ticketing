class AddPublishedToTweets < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :published, :boolean, null: true, default: true
  end
end
