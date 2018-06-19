class AddUserIdToTaggings < ActiveRecord::Migration[5.2]
  def change
    add_column :taggings, :user_id, :integer
    add_column :users, :tag_email_notifications, :boolean, default: false
  end
end
