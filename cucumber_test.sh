cd rails_repo/paperjuice/ && git pull origin staging

# This script prepares the server to run cucumber in a headless
# firefox browser using Xvfb.  Make sure that the new build is downloaded
# before running bundle install

bundle install
pwd
service postgresql-9.3 start
bundle exec rake db:drop RAILS_ENV=test
bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:schema:load RAILS_ENV=test

# Run in init.d ( http://goo.gl/bB0YCF )
# Xvfb :5-ac -screen 0 1024x768x16
# init.d script for xvfb: http://goo.gl/1U3c8x
service xvfb start
DISPLAY=:5 bundle exec cucumber
service xvfb stop
#rake db:drop
service postgresql-9.3 stop
