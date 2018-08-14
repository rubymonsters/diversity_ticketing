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
        csv << [ "Year", year ]

        csv << ["User registrations", User.all.where('created_at > ? AND created_at < ?', Date.new(year, 01, 01), Date.new(year, 12, 31)).count]

        csv << ["Total event submissions", Event.all.where('start_date > ? AND start_date < ?', Date.new(year, 01, 01), Date.new(year, 12, 31)).count]

        events = Event.approved.where('start_date > ? AND start_date < ?', Date.new(year, 01, 01), Date.new(year, 12, 31))

        csv << ["Number of approved events", events.count]

        number_of_tickets_offered = events.map do |event|
          event.number_of_tickets
        end.inject { |sum,n| sum += n }

        csv << ["Tickets offered", number_of_tickets_offered ]

        number_of_tickets_provided = events.map do |event|
          event.applications.where(status: "approved").count
        end.inject { |sum,n| sum += n }

        csv << ["Tickets provided via 'Travis Selection'", number_of_tickets_provided ]

        csv << ["Geographical distribution"]

        countries = events.pluck(:country).uniq

        countries.map do |c|
          csv << [c, events.where(country: c).count ]
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

        events.each do |event|
          csv << [
            event.id,
            event.name,
            event.city,
            event.country,
            event.start_date,
            event.end_date,
            event.application_process,
            event.number_of_tickets,
            event.applications.count
          ]

          csv << []
        end
      end
    end
  end

  def self.user_data(user_params)
    result = User.find_by(id: user_params.id)
    applications = result.applications

    CSV.generate do |csv|
      csv << [
        "User ID",
        "Name",
        "Email",
        "Country",
        "Created at",
        "Updated at",
        "Email notifications: Local event, on?",
        "Email notifications: Events about fields of interest, on?",
        "Email notifictions: Send reminder when ticket capacity is reached",
        "Number of applications"
      ]

      csv << [
        result["id"],
        result["name"],
        result["email"],
        result["country"],
        result["created_at"],
        result["updated_at"],
        result["country_email_notifications"],
        result["tag_email_notifications"],
        result["capacity_email_notifications"],
        result.applications.count
      ]

      csv << []

      csv << [
        "Application for event",
        "Name on application",
        "Email on application",
        "Accepted Terms and Conditions?",
        "Application created at",
        "Application updated at",
        "Answer to question 1",
        "Answer to question 2",
        "Ticket needed?",
        "Travel needed?",
        "Accommodation needed?",
        "Visa needed?",
        "Application submitted?",
        "Status of application",

      ]

      applications.each do |application|
        csv << [
          application["event_id"],
          application["name"],
          application["email"],
          application["terms_and_conditions"],
          application["created_at"],
          application["updated_at"],
          application["attendee_info_1"],
          application["attendee_info_2"],
          application["ticket_needed"],
          application["travel_needed"],
          application["accommodation_needed"],
          application["visa_needed"],
          application["submitted"],
          application["status"]
        ]
      end
    end
  end
end
