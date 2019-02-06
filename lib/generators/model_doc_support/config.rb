# frozen_string_literal: true

module Generators::ModelDocSupport
  module Config
    cattr_accessor :overwrite do
      false
    end
  end
end
