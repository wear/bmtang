Comatose.configure do |config|
  # Sets the text in the Admin UI's title area
  config.admin_title = "Site Content"
  config.admin_sub_title = "Content for the rest of us..."  
  config.helpers <<  :application_helper
  config.helpers <<  :base_helper 
  config.includes << :authenticated_system 
  config.admin_includes << :authenticated_system 
  config.default_filter = 'Textile'
end
