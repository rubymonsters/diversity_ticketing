class ApplicantMailer < ApplicationMailer

	def application_received(application)
		@application = application
    mail(to: @application.email, subject: "Your application for #{@application.event.name}.")
	end

end
