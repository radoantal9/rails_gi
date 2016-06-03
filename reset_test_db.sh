rake db:drop RAILS_ENV=test
rake db:create RAILS_ENV=test
rake db:migrate RAILS_ENV=test # not rake db:schema:load because bugz