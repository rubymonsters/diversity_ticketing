require 'test_helper'

class ApplicationProcessTest < ActiveSupport::TestCase
  describe 'handling application process' do
    it 'is valid if its value is allowed' do
      choice = ApplicationProcess::Choice.new('selection_by_organizer')

      assert_equal true, choice.valid?
    end

    it 'is not valid if its value is not allowed' do
      choice = ApplicationProcess::Choice.new('random value')

      assert_equal false, choice.valid?
    end

    it 'reports it is a selection by travis event' do
      choice = ApplicationProcess::Choice.new('selection_by_travis')

      assert choice.selection_by_travis?
    end

    it 'reports it is not an application by organizer event' do
      choice = ApplicationProcess::Choice.new('selection_by_travis')

      assert !choice.application_by_organizer?      
    end
  end

  describe 'cleaning event params' do
    it 'gets rid of data protection check and application link if selection by Travis' do
      event_params = {
        application_process: 'selection_by_travis',
        data_protection_confirmation: '1',
        application_link: 'some_link.org'
      }

      clean_event_params = ApplicationProcess::Params.clean(event_params)

      assert_equal clean_event_params, {application_process: 'selection_by_travis'}
    end

    it 'gets rid of application link if selection by organizer' do
      event_params = {
        application_process: 'selection_by_organizer',
        data_protection_confirmation: '1',
        application_link: 'some_link.org'
      }

      clean_event_params = ApplicationProcess::Params.clean(event_params)

      assert_equal clean_event_params, {application_process: 'selection_by_organizer', data_protection_confirmation: '1'}
    end

    it 'gets rid of data protection check if application_by_organizer' do
      event_params = {
        application_process: 'application_by_organizer',
        data_protection_confirmation: '1',
        application_link: 'some_link.org'
      }

      clean_event_params = ApplicationProcess::Params.clean(event_params)

      assert_equal clean_event_params, {application_process: 'application_by_organizer', application_link: 'some_link.org'}
    end
  end
end
