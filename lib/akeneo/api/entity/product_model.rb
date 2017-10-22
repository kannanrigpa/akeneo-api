require 'time'
require 'active_support/core_ext/hash/indifferent_access'
require 'akeneo/api/no_client_exception'
require "akeneo/api/entity/abstract"

module Akeneo::Api::Entity
  class ProductModel < Abstract
    def self::properties
      return [
        :code, :family_variant, :parent, :categories, :values, :created, :updated
      ]
    end

    def endpoint
      return @_client.product_models
    end

    def self::unique_identifier
      return :code
    end

    def initialize(params = {})
      super
      params = params.with_indifferent_access

      @categories = [] if @categories.nil?
      @values = {} if @values.nil?

      self.class.properties.each do |arg|
        self.class.class_eval("def #{arg}=(val);@#{arg} = val;@updated = Time.now;end")
      end
    end

    def self::new_from_api(client, params = {})
      if (!params['family_variant'].nil?) then
        params['family_variant'] = Akeneo::Api::Entity::FamilyVariant.new({
          code: params['family_variant'],
          _client: client,
          _persisted: true,
          _loaded: false,
        })
      end
      if (!params['parent'].nil?) then
        params['parent'] = self.new({
          code: params['parent'],
          _client: client,
          _persisted: true,
          _loaded: false,
          })
      end

      params['created'] = params['created'].nil? ? Time.now : Time.parse(params['created'])
      params['updated'] = params['updated'].nil? ? Time.now : Time.parse(params['updated'])

      return super(client, params)
    end

    def to_api
      return {
        code: code,
        family_variant: family_variant.try(&:code),
        parent: parent.try(&:code),
        categories: categories,
        values: values,
        created: created,
        updated: updated
      }
    end
  end
end
