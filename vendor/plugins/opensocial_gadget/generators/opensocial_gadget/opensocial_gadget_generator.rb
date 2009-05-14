require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")
class OpensocialGadgetGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_root

  def initialize(runtime_args, runtime_options = {})
    super
    @plugin_root = Pathname.new(File.join(File.dirname(__FILE__), '..', "..")).relative_path_from(Pathname.new(RAILS_ROOT))
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', class_path) 
      m.directory File.join('app/helpers', class_path) 
      m.directory File.join('app/views', class_path, file_name) 
      m.directory File.join('test/functional', class_path) 

      # Controller class, functional test, and helper class.
      m.template 'controller.rb',
                  File.join('app/controllers', class_path, "#{file_name}_controller.rb"),
                  :collision => :ask

      m.template 'controller_test.rb',
                  File.join('test/functional', class_path, "#{file_name}_controller_test.rb"),
                  :collision => :ask

      m.template 'helper.rb',
                  File.join('app/helpers', class_path, "#{file_name}_helper.rb"),
                  :collision => :ask

      # View template
      m.template 'view.xml.erb',
                  File.join('app/views', class_path, file_name, "index.xml.erb"),
                  :collision => :ask

      # Config template
      m.template 'config.yml',
                  File.join('config', "gadget.yml"),
                  :collision => :ask

      # add routes
      m.route_name('connect', "/#{file_name}.xml", :controller => file_name, :action => 'index', :format => 'xml')

    end
  end
end
