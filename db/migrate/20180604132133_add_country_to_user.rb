class AddCountryToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :country, :string
  end
end
