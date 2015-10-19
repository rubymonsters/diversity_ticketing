class HomeController < ApplicationController
  skip_before_action :authenticate

	def home
	end
end