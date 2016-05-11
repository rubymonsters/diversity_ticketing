class AddManageApplicationsOptionsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :manage_applications, :string
  end
end
