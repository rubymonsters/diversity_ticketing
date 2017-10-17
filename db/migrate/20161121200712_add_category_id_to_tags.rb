class AddCategoryIdToTags < ActiveRecord::Migration
  def change
    add_reference :tags, :category, index: true
  end
end
