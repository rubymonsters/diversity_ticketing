class AddApplicationProcessToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :application_process, :string
  end
end
