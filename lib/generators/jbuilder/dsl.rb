module Generators::Jbuilder
  module DSL
    def self.included(base)
      base.extend Generators::Jbuilder::ClassMethods
    end
  end

  module ClassMethods
    include Generators::Helpers

    def api action, summary = '', builder: nil, **args, &block
      api = super(action, summary, **args, &block)
      return unless Rails.env.development?
      return if api.nil?
      generate(api.action_path, builder)
    end

    def generate(action_path, builder)
      return unless (config = Generators::Jbuilder::Config).enable
      return if builder.nil?
      builder = :default if builder == true

      path, action = action_path.split('#')
      dir_path = "app/views/#{path}"
      FileUtils.mkdir_p dir_path
      file_path = "#{dir_path}/#{action}.json.jbuilder"

      if config.overwrite || !File.exist?(file_path)
        write :JBuilder, config.templates[builder], to: file_path
      end
    end
  end
end
