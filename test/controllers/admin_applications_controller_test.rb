require 'test_helper'

class AdminApplicationsControllerTest < ActionController::TestCase
  describe '#destroy' do
    it 'properly redirects after successful deletion' do
      user = make_user(admin: true)
      sign_in_as(user)

      event = make_event
      application = make_application(event)
      applications = event.applications

      assert_equal 1, applications.count

      delete :destroy, params: { event_id: event.id, id: application.id }

      assert_redirected_to event_admin_path(event)
      assert_equal 0, applications.count
    end
  end
end
