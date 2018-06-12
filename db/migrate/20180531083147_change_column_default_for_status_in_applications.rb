class ChangeColumnDefaultForStatusInApplications < ActiveRecord::Migration[5.2]
  def change
    change_column_default :applications, :status, "pending"
  end
end
