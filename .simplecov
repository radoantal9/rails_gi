SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
end

SimpleCov.merge_timeout 3600