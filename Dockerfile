FROM ubuntu:14.04

RUN apt-get update && apt-get install -y -qq \
	cron \
	git \
	curl \
	nodejs \
	memcached \
	nginx \
	ruby-dev \
	imagemagick \
	imagemagick-common \
	libpq-dev \
	libsasl2-dev \
	htop \
	sendmail \
	build-essential \
	rubygems-integration \
	monit \
	vim

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
	curl -sSL https://get.rvm.io | bash -s stable && \
	rvm requirements && \
	rvm install 2.1.2 && \
	gem install bundler --no-ri --no-rdoc && \
	gem install foreman --no-ri --no-rdoc && \
	gem install pg -v '0.17.1' --no-ri --no-rdoc && \
	gem install fog-softlayer -v '0.3.23' --no-ri --no-rdoc && \
	gem install json -v '1.8.1' --no-ri --no-rdoc && \
	gem install eventmachine -v '1.0.7' --no-ri --no-rdoc && \
	echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
	chown -R www-data:www-data /var/lib/nginx

# Add default nginx and unicorn config
ADD docker_config/nginx-sites.conf /etc/nginx/sites-enabled/default
ADD docker_config/unicorn.rb /usr/src/app/config/unicorn.rb

# run bundle install in a smart caching way
# Copy the Gemfile and Gemfile.lock into the image. 
# Temporarily set the working directory to where they are. 
WORKDIR /tmp 
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD vendor/cache vendor/cache
RUN ["/bin/bash", "-l", "-c", "rvm use 2.1.2 && ruby -v && bundle install"] 

# Everything up to here was cached. This includes
# the bundle install, unless the Gemfiles changed.
# Now copy the app into the image.
ADD ./ /usr/src/app
WORKDIR /usr/src/app

# Make volume available at /usr/src/app

EXPOSE 80

CMD ["/bin/bash", "-l", "-c", "rvm use 2.1.2 && /usr/src/app/run_cmd.sh"]
