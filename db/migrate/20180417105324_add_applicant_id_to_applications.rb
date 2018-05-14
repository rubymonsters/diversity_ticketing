class AddApplicantIdToApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :applications, :applicant_id, :integer
  end
end
