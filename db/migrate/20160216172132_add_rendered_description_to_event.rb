class AddRenderedDescriptionToEvent < ActiveRecord::Migration
  def change
    add_column :events, :rendered_description, :text
  end
end
