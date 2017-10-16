require 'json'

module Akeneo::Api
    class QueryException < StandardError
        def initialize(body)
            json = JSON.parse(body)
            super("#{json['message']} - code: #{json['code']} - errors: #{json['errors']}")
        end
    end
end
