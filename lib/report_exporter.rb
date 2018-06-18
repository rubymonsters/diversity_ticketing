require 'csv'

module ReportExporter
  def self.events_report
    CSV.generate do |csv|
      csv << [
        "Event ID",
        "Name",
        "City",
        "Country",
        "Start Date",
        "End Date",
        "Application Process",
        "Number of Tickets",
        "Number of Applications"
      ]

      query = <<-SQL
        SELECT
          e.id "event_id",
          e.name,
          e.city,
          e.country,
          e.start_date,
          e.end_date,
          e.application_process,
          e.number_of_tickets,
          COUNT(a.*) "applications" FROM events e
        LEFT JOIN applications a ON e.id = a.event_id
        WHERE e.approved AND e.deadline < NOW()
        GROUP BY e.id
        ORDER BY e.created_at;
      SQL

      results = ActiveRecord::Base.connection.execute(query).to_a

      results.each do |result|
        csv << [
          result["event_id"],
          result["name"],
          result["city"],
          result["country"],
          result["start_date"],
          result["end_date"],
          result["application_process"],
          result["number_of_tickets"],
          result["applications"]
        ]
      end
    end
  end

  def self.annual_events_report
    years = Event.all.pluck(:start_date).compact.map{|date| date.year}.uniq.sort

    CSV.generate do |csv|
      years.each do |year|
        csv << [ "Year",
                 year ]

        csv << ["User registrations", User.all.where('created_at <= ?', Date.new(year,12,31)).count]

        csv << ["Number of events", Event.all.where('start_date <= ?', Date.new(year, 12, 31)).count]

        results = Event.all.where('start_date <= ?', Date.new(year, 12, 31))

        csv << ["Geographical distribution"]

        countries = results.pluck(:country).uniq

        countries.map do |c|
          csv << [c, results.where(country: c).count ]
        end

        csv << [
          "Event ID",
          "Name",
          "City",
          "Country",
          "Start Date",
          "End Date",
          "Application Process",
          "Number of Tickets",
          "Number of Applications"
        ]

        results.each do |result|
          csv << [
            result.id,
            result.name,
            result.city,
            result.country,
            result.start_date,
            result.end_date,
            result.application_process,
            result.number_of_tickets,
            result.applications.count
          ]
        end
      end
    end
  end
end
