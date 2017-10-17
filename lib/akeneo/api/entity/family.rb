require "akeneo/api/entity/abstract"

module Akeneo::Api::Entity
	class Family < Abstract
        def self::properties
            return [
                :attribute_as_label, :attribute_as_image, :attributes, :attribute_requirements, :labels
            ]
        end

        def self::endpoint
            return :families
        end

        def self::unique_identifier
            return :code
        end

        def initialize(params = {})
            super
            params = params.with_indifferent_access

            @code = params['code']
            @attribute_as_label = params['attribute_as_label']
            @attribute_as_image = params['attribute_as_image']
            @attributes = params['attributes'] || []
            @attribute_requirements = params['attribute_requirements'] || {}
            @labels = params['labels'] || {}
        end
    end
end
