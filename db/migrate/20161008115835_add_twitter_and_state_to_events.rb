class AddTwitterAndStateToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :twitter_handle, :string
    add_column :events, :state_province, :string
  end
end
