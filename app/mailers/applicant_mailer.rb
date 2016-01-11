class ApplicantMailer < ApplicationMailer

	def application_received(application)
		@application = application
    mail(to: @application.email, subject: "Thanks for applying for #{@application.event.name}.")
	end
	
end
