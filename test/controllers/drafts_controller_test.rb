require 'test_helper'

class DraftsControllerTest < ActionController::TestCase
  describe '#create' do
    it 'creates drafts for applications for a certain event' do
      user = make_user
      event = make_event

      sign_in_as(user)

      get :create, params: { event_id: event.id, application: { applicant_id: user.id } }

      assert_equal Application.last.applicant_id, user.id
      assert_equal Application.last.event, event
    end

    it 'does not allow to create drafts if the user is not logged in' do
      user = make_user
      event = make_event

      get :create, params: { event_id: event.id, application: { applicant_id: user.id } }

      assert_redirected_to sign_in_path
    end
  end

  describe '#update' do
    it 'updates drafts attributes' do
      user = make_user
      event = make_event
      draft = make_draft(event, applicant_id: user.id)

      sign_in_as(user)

      post :update, params: { event_id: event.id, id: draft.id, application: { name: "New name" } }
      draft.reload

      assert_equal draft.name, 'New name'
    end
  end
end
