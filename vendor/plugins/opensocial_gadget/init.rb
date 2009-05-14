# Include hook code here
require File.join(File.dirname(__FILE__), 'lib', 'opensocial_gadget', 'connection') 
require File.join(File.dirname(__FILE__), 'lib', 'opensocial_gadget', 'config') 
require File.join(File.dirname(__FILE__), 'lib', 'opensocial_gadget', 'controller_extensions') 
if defined?(RAILS_ROOT) and OpenSocialGadget::Config.file_exists?
  OpenSocialGadget::Config.load
end

#ActionController::Base.send(:include, OpenSocialGadget::ControllerExtensions)
