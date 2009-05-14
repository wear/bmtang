require 'yaml'
require 'erb'

module OpenSocialGadget
  module Config

    FILE = 'config/gadget.yml'
    
    def self.file_exists?(yaml_config=nil)
      yaml_config ||= File.join(RAILS_ROOT, FILE)
      File.exists?(yaml_config)
    end

    def self.load(yaml_config=nil)
      yaml_config ||= File.join(RAILS_ROOT, FILE)
      config = ::YAML::load(ERB.new(IO.read(yaml_config)).result)
      config.each do |key,value|
        ::OpenSocialGadget::Config.instance_eval %Q{
          @#{key} = ""
          def self.#{key}
            @#{key}
          end
        }
        ::OpenSocialGadget::Config.instance_variable_set("@#{key}", value)
      end
    end

  end
end
