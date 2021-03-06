module Generators::Rspec
  module Request
    module Helpers
      def default_context
        "it { expect(json['code']).to eq 200 }  "
      end

      def _request_params
        if (examples = describe_doc.doc[:examples]).present?
          self.let_param_name = examples.first.keys[0]
          pr(Hash[ examples.first[let_param_name][:value].map { |k, v| [k.to_sym, v] } ])
        else
          self.let_param_name = 'params'
          params_doc = describe_doc.doc['parameters'] || [ ]
          params_keys = params_doc.map { |p| p['name'] } - [:id]
          flatten_examples = params_keys.map do |key|
            value = Generators::Rspec::Config.params[key.to_sym] || params_doc[params_keys.index(key)]['schema']['type']
            [key.to_sym, value]
          end
          pr Hash[flatten_examples]
        end
      end

      def _request_by(merge = nil, params = { })
        params = merge if merge.is_a? Hash
        params = merge == :merge ? ", #{let_param_name}.merge(#{pr(params)})" : ", #{pr(params)}" if params.present?
        # url = describe_doc.path.match?('{') ? %("#{describe_doc.path.gsub('{', '#{')}") : "'#{describe_doc.path}'"
        url = describe_doc.doc['operationId']
        %(#{describe_doc.verb} :#{url}#{params if params.present?})
      end

      # TODO: refactoring
      def _expect(who, whos, what, not_what)
        if who.is_a? Hash
          who.map do |obj_name, exp_value|
            exp_value = _error_info(exp_value)
            exp_value = exp_value.is_a?(Symbol) && exp_value.match?(' ') ? exp_value.to_s : "eq #{exp_value}"
            "expect(#{obj_name.to_s.delete('!')}).#{obj_name['!'] ? 'not_to' : 'to'} #{exp_value}"
          end
        elsif whos.is_a? Hash
          whos.map do |obj_name, exp_value|
            exp_value = _error_info(exp_value)
            exp_value = exp_value.is_a?(Symbol) && exp_value.match?(' ') ? exp_value.to_s : "eq #{exp_value}"
            "expect(json['#{obj_name.to_s.delete('!')}']).#{obj_name['!'] ? 'not_to' : 'to'} #{exp_value}"
          end
        else
          obj = whos ? "json['#{whos}']" : who || 'json'
          [ what, not_what ].map do |w|
            next if w.nil?
            w = _error_info(w)
            exp_str = w.is_a?(Symbol) && w.match?(' ') ? "to #{w}" : "to eq #{w}"
            exp_str = "not_#{exp_str}" if not_what
            "expect(#{obj}).#{exp_str}"
          end.compact
        end.join("\n") << '  '
      end

      def whole_file
        <<~OUTER
          # frozen_string_literal: true

          require 'rails_helper'
          require 'dssl/request'
          
          RSpec.describe '#{ctrl_path.split('/')[0..-2].join(' ').upcase}', '#{ctrl_path.split('/').last}', type: :request do
            happy_spec
            # path id: 1

            #{add_ind_to content_stack.last}
          end
        OUTER
      end
    end
  end
end
