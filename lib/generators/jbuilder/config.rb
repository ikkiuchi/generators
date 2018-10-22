module Generators::Jbuilder
  module Config
    cattr_accessor :enable do
      true
    end

    cattr_accessor :overwrite do
      false
    end

    cattr_accessor :templates do
      {
          index: (
          <<~FILE
            json.partial! 'api/base'
  
            json.data do
              json.total @view[:data].size
              json.list  @view[:data]
            end
          FILE
          ),

          cache_index: (
          <<~FILE
            json.partial! 'api/base'
  
            json.cache! [ 'TODO: key' ], expires_in: 10.minutes do
              json.total @view[:data].size
              json.list  @view[:data]
            end
          FILE
          ),

          show: (
          <<~FILE
            json.partial! 'api/base'

            json.data @view[:datum].to_builder
          FILE
          ),

          cache_show: (
          <<~FILE
            json.partial! 'api/base'
    
            json.cache! [ 'TODO: key' ], expires_in: 10.minutes do
              json.datum @view[:datum].to_builder
            end
          FILE
          ),

          success: (
          <<~FILE
            json.partial! 'api/success'
          FILE
          ),

          default: (
          <<~FILE
            json.partial! 'api/base'
          FILE
          ),
      }
    end
  end
end
