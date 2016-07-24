class AddApplicationLinkToEvents < ActiveRecord::Migration
  def change
    add_column :events, :application_link, :text
  end
end
