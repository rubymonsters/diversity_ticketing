class AddLogoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :logo, :text
  end
end
