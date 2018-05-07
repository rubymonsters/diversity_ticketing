class ApplicantMailer < ApplicationMailer

	def application_received(application)
		@application = application
    mail(to: @application.email, subject: "Your application for #{@application.event.name}.")
	end

	def deadline_reminder(application)
		@application = application
		mail(to: @application.email, subject: "#{@application.event.name} deadline in two days.")
	end

end
