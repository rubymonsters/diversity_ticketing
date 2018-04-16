class CreateCategoriesService
  def self.create_categories
    categories = YAML.load_file("config/categories.yml")
    categories.each do |category_name, tag_names|
      category = Category.find_or_create_by(name: category_name)
      tag_names.each do |tag_name| 
        tag = Tag.find_or_create_by(name: tag_name, category: category)
        if tag.previous_changes.any?
          puts "Created tag: #{tag.name} (belongs to category: #{category.name})."
        end
      end
    end
  end
end