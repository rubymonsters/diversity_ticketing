# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

event1 = Event.create(name: "RubyConf", start_date: "2015-12-20", end_date: "2015-12-22", 
  description: "The International Ruby Conference – more commonly known as RubyConf – 
  has been the main annual gathering of Rubyists from around the world since 2001. 
  Focused on fostering the Ruby programming language and the robust community that 
  has sprung up around it, RubyConf brings together Rubyists both established and 
  new to discuss emerging ideas, collaborate, and socialize in some of the best 
  locations in the US. Come join us in San Antonio for what will surely be the best 
  RubyConf yet!", organizer_name: "Klaus Mustermann", organizer_email: "klaus@example.com", 
  organizer_email_confirmation: "klaus@example.com", approved: true)

event2 = Event.create(name: "CSSConf", start_date: "2015-12-12", end_date: "2015-12-12", 
  description: "CSSConf is a conference dedicated to the designers, developers and engineers 
  who build the world’s most engaging user interfaces. The presenters push the boundaries of 
  what is possible — talking about the latest technologies, cutting edge techniques, and tools.", 
  organizer_name: "Lina Klein", organizer_email: "lina@example.com", 
  organizer_email_confirmation: "lina@example.com", approved: true)

Application.create(name: "Lea Humphreys", email: "lea@example.com", email_confirmation: "lea@example.com",
  event: event1)

Application.create(name: "Greta Rudolf", email: "greta@example.com", email_confirmation: "greta@example.com",
  event: event1)

Application.create(name: "Maria Wild", email: "maria@example.com", email_confirmation: "maria@example.com",
  event: event2)