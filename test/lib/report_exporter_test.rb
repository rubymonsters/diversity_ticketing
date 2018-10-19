require 'test_helper'
require 'report_exporter'

class ReportExporterTest < ActiveSupport::TestCase
  describe 'events report' do
    before do
      @event = make_event(
        start_date: Date.new(2017,9,13),
        end_date: Date.new(2017,9,14),
        deadline: Date.new(2017,9,3),
        approved: true,
        name: 'My Event',
        city: 'Berlin',
        country: 'Germany',
        number_of_tickets: 10,
        application_process: 'selection_by_travis'
      )
      3.times { make_application(@event) }
    end

    it 'accumulates data from approved past events' do
      report = ReportExporter.events_report.split("\n")

      assert_equal(report[0], "Event ID,Name,City,Country,Start Date,End Date,Application Process,"\
        "Number of Tickets,Number of Applications")
      assert_equal(report[1], "#{@event.id},My Event,Berlin,Germany,2017-09-13,2017-09-14,"\
        "selection_by_travis,10,3")
    end

    it 'does not include events that are not approved' do
      @event.update(approved: false)

      report = ReportExporter.events_report.split("\n")

      assert_equal(report[0], "Event ID,Name,City,Country,Start Date,End Date,Application Process,"\
        "Number of Tickets,Number of Applications")
      assert_nil(report[1])
    end

    it 'does not include events where applications are still open' do
      @event.update(end_date: 3.days.from_now, deadline: 2.days.from_now)

      report = ReportExporter.events_report.split("\n")

      assert_equal(report[0], "Event ID,Name,City,Country,Start Date,End Date,Application Process,"\
        "Number of Tickets,Number of Applications")
      assert_nil(report[1])
    end
  end

  describe 'annual_events_report' do
    before do
      @event = make_event(
        start_date: Date.new(2017,9,13),
        end_date: Date.new(2017,9,14),
        deadline: Date.new(2017,9,3),
        approved: true,
        name: 'My Event',
        city: 'Berlin',
        country: 'Germany',
        number_of_tickets: 10,
        application_process: 'selection_by_travis',
        approved_tickets: 3
      )
      3.times { make_application(@event) }
      @event_old = make_event(
        start_date: Date.new(2016,9,13),
        end_date: Date.new(2016,9,14),
        deadline: Date.new(2016,9,3),
        approved: true,
        name: 'My Event',
        city: 'Berlin',
        country: 'Germany',
        number_of_tickets: 10,
        application_process: 'selection_by_travis'
      )
      4.times { make_application(@event_old, status: "approved") }
    end

    it 'accumulates data from approved past events since the beginning of the app' do
      report = ReportExporter.annual_events_report.split("\n")

      assert_equal(report[0], "Year,2016")
      assert_equal(report[1], "User registrations,0")
      assert_equal(report[2], "Total event submissions,1")
      assert_equal(report[3], "Number of approved events,1")
      assert_equal(report[4], "Tickets offered,10")
      assert_equal(report[5], "Tickets provided (total),4")
      assert_equal(report[6], "Tickets provided via 'Travis Selection',4")
      assert_equal(report[7], "Geographical distribution")
      assert_equal(report[8], "Germany,1")
      assert_equal(report[9], "Event ID,Name,City,Country,Start Date,End Date,Application Process,Number of Tickets,Number of Applications")
      assert_equal(report[10], "#{@event_old.id},My Event,Berlin,Germany,2016-09-13,2016-09-14,selection_by_travis,10,4")
      assert_equal(report[12], "Year,2017")
      assert_equal(report[13], "User registrations,0")
      assert_equal(report[14], "Total event submissions,1")
      assert_equal(report[15], "Number of approved events,1")
      assert_equal(report[16], "Tickets offered,10")
      assert_equal(report[17], "Tickets provided (total),3")
      assert_equal(report[18], "Tickets provided via 'Travis Selection',0")
      assert_equal(report[19], "Geographical distribution")
      assert_equal(report[20], "Germany,1")
      assert_equal(report[21], "Event ID,Name,City,Country,Start Date,End Date,Application Process,Number of Tickets,Number of Applications")
      assert_equal(report[22], "#{@event.id},My Event,Berlin,Germany,2017-09-13,2017-09-14,selection_by_travis,10,3")
    end
  end

  describe '#user_data' do
    before do
      @user = make_user
      @event = make_event
      @application = make_application(@event, { applicant_id: @user.id, status: "approved" })
    end
    it 'accumulates data from the user' do
      report = ReportExporter.user_data(@user).split("\n")

      assert_equal(report[0], "User ID,Name,Email,Country,Created at,Updated at,\"Email notifications: Local event, on?\",\"Email notifications: Events about fields of interest, on?\",Email notifictions: Send reminder when ticket capacity is reached,Number of applications")
      assert_equal(report[1], "#{@user.id},Awesome name,awesome@example.org,,#{@user.created_at},#{@user.updated_at},false,false,OFF,1")
      assert_equal(report[3], "Application for event,Name on application,Email on application,Accepted Terms and Conditions?,Application created at,Application updated at,Answer to question 1,Answer to question 2,Ticket needed?,Travel needed?,Accommodation needed?,Visa needed?,Application submitted?,Status of application")
      assert_equal(report[4], "#{@event.id},Joe,joe@test.com,true,#{@application.created_at},#{@application.updated_at},some text,some text,false,false,false,false,true,approved")
    end
  end
end
