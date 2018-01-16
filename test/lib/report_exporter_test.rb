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
      @event.update(deadline: 2.days.from_now)

      report = ReportExporter.events_report.split("\n")

      assert_equal(report[0], "Event ID,Name,City,Country,Start Date,End Date,Application Process,"\
        "Number of Tickets,Number of Applications")
      assert_nil(report[1])
    end
  end
end
