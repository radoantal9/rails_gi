echo "Running run_cmd.sh...."
echo "Rails environment:"
echo $RAILS_ENV

if [ "$RAILS_ENV" == "development" ]; then
  echo "Running rails in dev mode"
  echo "Connecting to DB Host:" $DB_PORT_5432_TCP_ADDR
  export DEV_DATABASE_HOST=$DB_PORT_5432_TCP_ADDR
  bundle exec rake db:setup
  bundle exec rake db:migrate
  memcached -d -u nobody
  rails s
fi

if [ "$WEB" == "true" ]; then
	echo "Running web server block"
  bundle exec rake assets:precompile --trace
	bundle exec unicorn -c config/unicorn.rb -D
	/usr/sbin/nginx -c /etc/nginx/nginx.conf &
fi

if [ "$WORKER" == "true" ]; then
	echo "Running worker block"
	start cron
	whenever --set "environment=$RAILS_ENV" --update-cron
	script/delayed_job start
fi

if [ "$MEMC" == "true" ]; then
	echo "Running memcached server"
	memcached -d -u nobody
fi


