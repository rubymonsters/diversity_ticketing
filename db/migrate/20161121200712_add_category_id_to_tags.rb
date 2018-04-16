class AddCategoryIdToTags < ActiveRecord::Migration[5.1]
  def change
    add_reference :tags, :category, index: true
  end
end
