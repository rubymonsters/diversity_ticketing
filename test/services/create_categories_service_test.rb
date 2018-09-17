require 'test_helper'

class CreateCategoriesServiceTest < ActiveSupport::TestCase
  describe 'creates categories and categories described in the category yaml'  do
    it 'generates the categories and tags' do
      CreateCategoriesService.create_categories

      first_category = File.open("config/categories.yml").to_a[7].strip.tr(":", "")
      first_tag = File.open("config/categories.yml").to_a[8].strip.tr("- ", "")

      assert_equal first_category, Category.first.name.downcase
      assert_equal first_tag, Tag.first.name
    end
  end
end
