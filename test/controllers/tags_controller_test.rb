require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  describe '#index' do
    it 'shows all Tags already created to admins' do
      setup do
        3.times { make_tag(name: "New event", category_id: 1) }
      end

      admin = make_user(admin: true)
      sign_in_as(admin)

      get :index

      assert_response :success
      assert_template 'tags/index'
    end

    it 'does not show all Tags already created to non-admins' do
      setup do
        3.times { make_tag(name: "New event", category_id: 1) }
      end

      user = make_user
      sign_in_as(user)

      get :index

      assert_redirected_to root_path
    end
  end

  describe '#create' do
    it 'allows an admin user to create a new tag with a name and a category' do
      admin = make_user(admin: true)
      sign_in_as(admin)

      put :create, params: { tag: { name: "New Tag", category_id: 1 } }

      assert_redirected_to tags_path
      assert_equal "Tag New Tag was successfully created.", flash[:notice]
      assert_equal Tag.last.name, "New Tag"
    end

    it 'shows a flash message if there was a problem creating the tag' do
      admin = make_user(admin: true)
      sign_in_as(admin)

      put :create, params: { tag: { name: "New Tag" } }

      assert_redirected_to tags_path
      assert_equal "There was a problem creating the new tag.", flash[:alert]
    end

    it 'does not allow non-admin user to create a new tag' do
      make_tag

      user = make_user
      sign_in_as(user)
      
      put :create, params: { tag: { name: "Non Created Tag", category_id: 1 } }

      assert_redirected_to root_path
      assert_not_equal "Non Created Tag", Tag.last.name
    end
  end

  describe '#destroy' do
    it 'allows admin to delete tags' do
      make_tag(name: "New event", category_id: 1)

      all_tags = Tag.all.count

      admin = make_user(admin: true)
      sign_in_as(admin)

      delete :destroy, params: { id: Tag.last.id }

      assert_redirected_to tags_path
      assert_equal all_tags - 1, Tag.all.count
    end
  end
end
