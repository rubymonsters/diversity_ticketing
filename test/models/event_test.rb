require 'test_helper'

class EventTest < ActiveSupport::TestCase
  describe 'checking the deadline' do
    it 'returns true when the deadline is in the future' do
      event = Event.new(deadline: 1.week.from_now)
      assert_equal true, event.open?
    end

    it 'returns false when the deadline is in the past' do
      event = Event.new(deadline: 1.week.ago)
      assert_equal false, event.open?
    end

    it 'deadline is midnight UTC' do
      event = Event.new(deadline: Date.new(2016, 4, 8))
      assert_equal ActiveSupport::TimeZone['UTC'].local(2016, 4, 8, 0, 0, 0), event.deadline
    end
  end

  describe 'validating organizer_email' do
    it 'should allow a valid email address' do
      event = Event.new(organizer_email: 'email@website.de')
      assert_attribute_valid(event, :organizer_email)
    end

    it 'should not allow an invalid email address' do
      event = Event.new(organizer_email: 'emailwebsite.de')
      assert_attribute_invalid(event, :organizer_email)
    end
  end

  describe 'validating website' do
    it 'should allow a valid url' do
      event = Event.new(website: 'http://www.example.com')
      assert_attribute_valid(event, :website)
    end

    it 'should allow a valid url without www' do
      event = Event.new(website: 'http://example.com')
      assert_attribute_valid(event, :website)
    end

    it 'should not allow an url without http or https' do
      event = Event.new(website: 'www.example.com')
      assert_attribute_invalid(event, :website)
    end

    it 'should not allow an invalid url' do
      event = Event.new(website: 'http://examplecom')
      assert_attribute_invalid(event, :website)
    end
  end

  describe 'validating application process' do
    it 'should not allow invalid application process' do
      event = Event.new(application_process: 'bad')
      assert_attribute_invalid(event, :application_process)
    end

    describe 'T&C confirmation checkbox' do
      it 'must be checked if organizers handle selection by themselves' do
        event = Event.new(application_process: 'selection_by_organizer', data_protection_confirmation: '0')
        assert_attribute_invalid(event, :data_protection_confirmation)
      end

      it 'should not be checked if organizers do not handle selection by themselves' do
        event = Event.new(application_process: 'selection_by_travis', data_protection_confirmation: '1')
        assert_attribute_invalid(event, :data_protection_confirmation)
      end
    end

    describe 'application_link' do
      it 'must be blank if application process not handled by organizer' do
        event = Event.new(application_process: 'selection_by_travis', application_link: 'https://something.org')

        assert_attribute_invalid(event, :application_link)
      end

      it 'should contain a valid link if application is handled by organizer' do
        event = Event.new(application_process: 'application_by_organizer')

        assert_attribute_invalid(event, :application_link)
      end
    end
  end

  describe 'upcoming' do
    it 'gets event with enddate on the same day' do
      make_event(start_date: '2016-07-24', end_date: '2016-07-25', deadline: '2016-07-24')

      assert_equal 1, Event.upcoming('2016-07-25 23:59:59').length
    end

    it 'does not get event with enddate on the day before' do
      make_event(start_date: '2016-07-24', end_date: '2016-07-25', deadline: '2016-07-24')

      assert_equal 0, Event.upcoming('2016-07-26 00:00:00').length
    end
  end

  describe 'past' do
    it 'does not get event with enddate on the same day' do
      make_event(start_date: '2016-07-24', end_date: '2016-07-25', deadline: '2016-07-24')

      assert_equal 0, Event.past('2016-07-25 23:59:59').length
    end

    it 'gets event with enddate on the day before' do
      make_event(start_date: '2016-07-24', end_date: '2016-07-25', deadline: '2016-07-24')

      assert_equal 1, Event.past('2016-07-26 00:00:00').length
    end
  end

  describe 'open' do
    it 'gets event with deadline on the same day' do
      make_event(deadline: '2016-07-26')

      assert_equal 1, Event.open('2016-07-25 23:59:59').length
    end

    it 'does not get event with deadline on the day before' do
      make_event(deadline: '2016-07-26')

      assert_equal 0, Event.open('2016-07-26 00:00:01').length
    end
  end

  describe 'closed' do
    it 'does not get event with deadline on the same day' do
      make_event(deadline: '2016-07-26')

      assert_equal 0, Event.closed('2016-07-25 23:59:59').length
    end

    it 'gets event with deadline on the day before' do
      make_event(deadline: '2016-07-26')

      assert_equal 1, Event.closed('2016-07-26 00:00:01').length
    end
  end

  describe 'events with deadline in two days' do
    it 'fetches only these events' do
      make_event(start_date: '2016-08-12', end_date: '2016-08-14', deadline: '2016-08-01')
      make_event(start_date: '2016-07-03', end_date: '2016-07-05', deadline: '2016-06-15')
      make_event(start_date: '2016-06-23', end_date: '2016-06-25', deadline: '2016-06-01')

      assert_equal 1, Event.deadline_in_three_days(DateTime.parse('2016-06-12')).length
    end
  end

  describe 'location' do
    it 'formats the loacation for event without state/province' do
      event = Event.new(city: 'Berlin', country: 'Germany', state_province: '')
      assert_equal 'Berlin, Germany', event.location
    end

    it 'formats the loacation for event with state/province' do
      event = Event.new(city: 'Berlin', country: 'United States', state_province: 'Wisconsin')
      assert_equal 'Berlin, Wisconsin, United States', event.location
    end
  end


  describe 'twitter_handle' do
    it 'leading @\'s are removed before saving to the database' do
      event = make_event(twitter_handle: '@lisbethmarianne')
      assert_equal 'lisbethmarianne', event.twitter_handle
    end

     it 'is not altered if there is no leading @' do
      event = make_event(twitter_handle: 'lisbethmarianne')
      assert_equal 'lisbethmarianne', event.twitter_handle
    end

    it 'event can be saved with no twitter handle' do
      event = make_event
      assert_nil event.twitter_handle
    end
  end

  describe 'to_csv' do
    it 'loads the correct information in the csv file' do
      event = make_event
      application = make_application(event)

      event.to_csv

      assert event.to_csv.include?(application.email)
      assert event.to_csv.include?(application.name)
      assert event.to_csv.include?(application.attendee_info_1)
      assert event.to_csv.include?(application.attendee_info_2)
    end
  end
end
