class User < ActiveRecord::Base
  include Clearance::User

  def self.admin
  	where(admin: true)
  end
end
