class CreateApplicationProcessOptionsHandler < ActiveRecord::Migration[5.2]
  def change
    create_table :application_process_options_handlers do |t|
      t.boolean :selection_by_dt_enabled, default: true, null: false
    end
  end
end
