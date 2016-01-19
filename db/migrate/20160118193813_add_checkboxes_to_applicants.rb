class AddCheckboxesToApplicants < ActiveRecord::Migration
  def change
    add_column :applications, :ticket_needed, :boolean, null: false, default: false
    add_column :applications, :travel_needed, :boolean, null: false, default: false
  	add_column :applications, :accommodation_needed, :boolean, null: false, default: false
  end
end
