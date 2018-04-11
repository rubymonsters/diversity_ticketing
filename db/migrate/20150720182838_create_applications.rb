class CreateApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
