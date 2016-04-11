require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  # To do: complete this for editing the password as well
	test "user can edit their data" do
    user = User.create(email: "la@le.lu", password: "123456")
    sign_in_as(user)
		
		put :update, id: user.id, email: "cool@email.add"

		assert_redirected_to user_path(user)
	end
end
