class AddApplicationProcessToEvents < ActiveRecord::Migration
  def change
    add_column :events, :application_process, :string
  end
end
