rails_env = new_resource.environment["RAILS_ENV"]
Chef::Log.info("Running deploy/before_symlink.rb...")
