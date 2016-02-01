class HomeController < ApplicationController
  skip_before_action :authenticate

	def home
	end

  def about
  end

  def faq
  end
end
