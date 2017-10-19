require "akeneo/api/entity/abstract"

module Akeneo::Api::Entity
	class Attribute < Abstract
        def self::properties
            return [
                :code, :type, :labels, :group, :sort_order, :localizable, :scopable, :available_locales, :unique,
                :useable_as_grid_filter, :max_characters, :validation_rule, :validation_regexp, :wysiwyg_enabled,
                :number_min, :number_max, :decimals_allowed, :negative_allowed, :metric_family, :default_metric_unit,
                :date_min, :date_max, :allowed_extensions, :max_file_size
            ]
        end

        def self::endpoint
            return :attributes
        end

        def self::unique_identifier
            return :code
        end

        def initialize(params = {})
            super
            params = params.with_indifferent_access

            @labels = params['labels'] || {}
            @available_locales = params['available_locales'] || []
            @allowed_extensions = params['allowed_extensions'] || []
        end

        def to_api
            return {
                code: code,
                type: type,
                labels: labels,
                group: group,
                sort_order: sort_order,
                localizable: localizable,
                scopable: scopable,
                available_locales: available_locales,
                unique: unique,
                useable_as_grid_filter: useable_as_grid_filter,
                max_characters: max_characters,
                validation_rule: validation_rule,
                validation_regexp: validation_regexp,
                wysiwyg_enabled: wysiwyg_enabled,
                number_min: number_min,
                number_max: number_max,
                decimals_allowed: decimals_allowed,
                negative_allowed: negative_allowed,
                metric_family: metric_family,
                date_min: date_min,
                date_max: date_max,
                allowed_extensions: allowed_extensions,
                max_file_size: max_file_size
            }
        end
    end
end
