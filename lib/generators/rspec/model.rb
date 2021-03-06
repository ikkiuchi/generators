module Generators::Rspec
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      include Generators::Rspec::Helpers
      include Generators::Rspec::DSL
      include Generators::Rspec::Model::Helpers

      def describe method = nil, add_desc = nil, desc: nil, template: nil, &block
        _biz add_desc, template: template, &block if method.nil?

        desc = desc_temp(desc) || method.is_a?(Symbol) ? "##{method}" : ".#{method}"
        desc << ", #{add_desc}" if add_desc
        sub_content = _instance_eval(block) if block_given?

        content_stack.last << <<~DESCRIBE
          func '#{desc}' do
            #{add_ind_to each[:describe]}
            #{add_ind_to sub_content}
          end
        DESCRIBE
        content_stack.last << "\n"
      end

      # TODO: auto gen desc
      def it does_what = nil, when: nil, then: nil, its: nil, then_its: nil,
             is_expected: nil, isnt_expected: nil, should: nil, shouldnt: nil, &block
        return oneline_it if does_what.nil?
        if (templates = Generators::Rspec::Config.it_templates).key?(does_what)
          content_stack.last << "it { #{templates[does_what]} }\n" and return
        end

        sub_content = _instance_eval(block) if block_given?
        what = is_expected || should
        not_what = isnt_expected || shouldnt
        expects = _expect(binding.local_variable_get(:then), its || then_its, what, not_what)
        content_stack.last << <<~IT
          it '#{_does_what(desc_temp(does_what), what || not_what)}' do
            #{add_ind_to expects}
            #{add_ind_to sub_content}
          end
        IT
        content_stack.last << "\n"
      end

      def oneline_it
        content_stack.last << <<~IT
          subject { '' }
          it { is_expected.to eq '' }
        IT
        content_stack.last << "\n"
      end

      # FIXME: hack
      def run
        rescue_no_method_run { super() }
        Dir['./app/_docs/others/spec_docs/*.rb'].each { |file| require file }
        descendants.each do |spdoc|
          *dir_path, file_name = spdoc.path.split('/')
          dir_path = "spec/#{dir_path.join('/')}"
          FileUtils.mkdir_p dir_path
          file_path = "#{dir_path}/#{file_name}#{spdoc.version}_spec.rb"

          if Generators::Rspec::Config.overwrite || !File::exist?(file_path)
            # if true
            write :Spec, spdoc.whole_file.sub("\n  XXX\n", ''), to: file_path
          end
        end
      end
    end
  end
end
