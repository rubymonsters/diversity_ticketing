class AddTermsAndConditionsToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :terms_and_conditions, :boolean, default: false, null: false
  end
end
