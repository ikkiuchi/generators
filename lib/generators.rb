# frozen_string_literal: true

require 'generators/version'

files = %w[
  helpers dsl
  api_doc_support/config api_doc_support/dsl
  jbuilder/config jbuilder/dsl
  model_doc_support/config model_doc_support/helpers model_doc_support/dsl
  rspec/config rspec/helpers rspec/dsl
  rspec/model/helpers rspec/model
  rspec/normal/helpers rspec/normal
  rspec/request/helpers rspec/request
].map! { |path| 'generators/' + path }

files.each { |file| require file }

module Generators
  # Your code goes here...
end
