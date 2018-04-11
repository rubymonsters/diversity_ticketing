class AddApplicationLinkToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :application_link, :text
  end
end
