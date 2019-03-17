module Generators::Rspec
  module Normal
    module Helpers
      def default_context
        "it { is_expected.to eq '' }  "
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
            "expect(subject.#{obj_name.to_s.delete('!')}).#{obj_name['!'] ? 'not_to' : 'to'} #{exp_value}"
          end
        else
          obj = whos ? "json['#{whos}']" : who || 'subject'
          [ what, not_what ].map do |w|
            next if w.nil?
            w = _error_info(w)
            exp_str = w.is_a?(Symbol) && w.match?(' ') ? "to #{w}" : "to eq #{w}"
            exp_str = "not_#{exp_str}" if not_what
            obj == 'subject' ? "is_expected.#{exp_str}" : "expect(#{obj}).#{exp_str}"
          end.compact
        end.join("\n") << '  '
      end

      def whole_file
        <<~OUTER
          # frozen_string_literal: true

          RSpec.describe #{path.split('/').last.camelize} do
            #{add_ind_to content_stack.last}
          end
        OUTER
      end
    end
  end
end
