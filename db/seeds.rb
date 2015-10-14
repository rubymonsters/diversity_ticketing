# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

event1 = Event.create(name: "RubyConf", start_date: "2015-12-20", end_date: "2015-12-22", 
  description: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium 
  doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et 
  quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas 
  sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione 
  voluptatem sequi nesciunt.", organizer_name: "Klaus Mustermann", organizer_email: "klaus@example.com", 
  organizer_email_confirmation: "klaus@example.com", approved: true)

event2 = Event.create(name: "CSSConf", start_date: "2015-12-12", end_date: "2015-12-12", 
  description: "Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. 
  Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in 
  li grammatica, li pronunciation e li plu commun vocabules.", 
  organizer_name: "Lina Klein", organizer_email: "lina@example.com", 
  organizer_email_confirmation: "lina@example.com", approved: true)

event3 = Event.create(name: "JSConf", start_date: "2015-09-10", end_date: "2015-09-12", 
  description: "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae 
  consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? At vero eos et accusamus et 
  iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores 
  et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia 
  deserunt mollitia animi, id est laborum et dolorum fuga.", 
  organizer_name: "Ina Biena", organizer_email: "ina@example.com", 
  organizer_email_confirmation: "ina@example.com", approved: true)

event4 = Event.create(name: "JRubyConf", start_date: "2015-11-20", end_date: "2015-11-25", 
  description: "Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi 
  traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.", 
  organizer_name: "Ottokar Paul", organizer_email: "otto@example.com", 
  organizer_email_confirmation: "otto@example.com", approved: false)

Application.create(name: "Lea Humphreys", email: "lea@example.com", email_confirmation: "lea@example.com",
  event: event1)

Application.create(name: "Greta Rudolf", email: "greta@example.com", email_confirmation: "greta@example.com",
  event: event1)

Application.create(name: "Maria Wild", email: "maria@example.com", email_confirmation: "maria@example.com",
  event: event2)