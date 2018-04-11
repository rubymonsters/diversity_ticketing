class AddLogoToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :logo, :text
  end
end
