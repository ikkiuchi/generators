# frozen_string_literal: true

module Generators::ApiDocSupport
  module DSL
    def self.included(base)
      base.extend Generators::ApiDocSupport::ClassMethods
    end
  end

  module ClassMethods
    include Generators::Helpers

    def api action, summary = '', http: nil, builder: nil, **args, &block
      api = super(action, summary, http: http, builder: builder, **args, &block)
      (@api_actions ||= { })[action] = { api: api, **(@path || { }) }
      @path = nil
    end

    def scope scope_path
      @scope = scope_path
    end

    %i[ get post patch put delete ].each do |verb|
      define_method verb do |path|
        @print_routes = true
        @path = { path: path, verb: verb }
      end
    end

    def match
      # TODO
    end

    def api_version
      @route_base.split('/')[1]
    end

    def api_name
      @route_base.split('/').last
    end

    def g version = nil
      ctrl_path = "app/controllers/#{@route_base}_controller#{version}.rb"
      spdoc_path = "app/_docs/others/spec_docs/api/#{@route_base.sub('api/', '')}#{version}.rb"
      biz_error_path = "app/_docs/error/#{api_name}#{version}.rb"

      write :Controller, controller_rb.sub("\n\nend", "\nend"), to: ctrl_path unless File::exist?(ctrl_path)
      write :SpecDoc, spdoc_rb, to: spdoc_path unless File::exist?(spdoc_path)
      write :BizError, error_rb, to: biz_error_path unless File::exist?(biz_error_path)
      print_routes if @print_routes
    end

    def controller_rb
      <<~CTRL
        # frozen_string_literal: true

        class #{@route_base.camelize}Controller < Api::#{api_version.upcase}::BaseController
          ##{api_name.singularize.camelize} ##{api_name.camelize}Doc #Error::#{api_name.camelize}
          include ActiveRecordErrorsRescuer
          ERROR = Error::#{api_name.camelize}
          #{add_ind_to skip_token}
          #{add_ind_to api_actions}
        end
      CTRL
    end

    # FIXME
    def skip_token
      skip = @api_actions.clone.keep_if { |_key, info| info[:security]&.include?(:Authorization => []) }.keys
      return "XXX\n" if skip.blank?
      "skip_token only: #{pr(skip)}\n"
    end

    def api_actions
      @api_actions.keys.map do |action|
        model = api_name.singularize.camelize
        impl = case action
          when :index   then "build_with data: #{model}.all"
          when :show    then "build_with datum: @#{model.underscore}"
          when :create  then "check #{model}.create! permitted"
          when :update  then "check @#{model.underscore}.update! permitted"
          when :destroy then "check @#{model.underscore}.destroy"
          else "# TODO\n  ok"
        end

        <<~ACTION
          def #{action}
            #{impl}
          end
        ACTION
      end.join("\n")
    end

    def describes
      @api_actions.keys.map do |action|
        <<~DESC
          describe :#{action} do
            # TODO
          end
        DESC
      end.join("\n")
    end

    def spdoc_rb
      <<~SPD
        # frozen_string_literal: true

        class SpecDocs::#{@route_base.camelize} < RequestSpecDoc
          #{add_ind_to describes}
        end
      SPD
    end

    def print_routes
      puts '    please make sure you have created the appropriate route, like this:'.yellow
      @api_actions.each do |action, info|
        next if (path = info[:path]).nil?
        to = path.split('/').last.to_sym == action ? '' : ", to: '#{api_name}##{action}'"
        puts "      #{info[:verb]} '#{path}'#{to}"
      end
    end

    def error_rb
      actions = @api_actions.keys.map do |action|
        "\n  # group :#{action} do\n  #   mattr_reader :ERROR_NAME\n  # end\n"
      end.join

      <<~ERROR_RB
        # frozen_string_literal: true

        class Error::#{api_name.camelize} < Error::Api
          # code_start_at 0

          # include Error::Concerns::Failed
          #{actions}
        end
      ERROR_RB
    end
  end
end
