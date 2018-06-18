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

  def self.anual_events_report
    years = Event.all.group_by(&:start_date).keys.map{|date| date.year}.uniq.sort

    CSV.generate do |csv|
      years.each do |year|
        csv << [ "Year", year ]

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
        "Country email notifictaions on?",
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
