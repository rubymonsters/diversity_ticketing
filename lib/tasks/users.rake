namespace :users do
  desc "Event organizers get user accounts"
  task give_accounts_to_accountless_organizers: :environment do
    organizerless_events = Event.where(organizer_id: nil)
    puts "Going to assign user accounts to event organizers that currently don't have one."

    ActiveRecord::Base.transaction do
      organizer_emails = organizerless_events.pluck(:organizer_email).uniq

      organizer_emails.each do |email|
        user = User.find_or_initialize_by(email: email)
        if user.new_record?
          user.encrypted_password = 'x'
          user.save!(validate: false)
        end
      end

      organizerless_events.each do |event|
        event.update!(organizer_id: User.find_by!(email: event.organizer_email).id)
      end
    end

    puts "Yay, done :)"
  end
end