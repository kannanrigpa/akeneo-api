require 'active_support/core_ext/object/try'

module Akeneo::Api::Entity
    class ProductSet
        extend Forwardable

        attr_accessor :_client, :first_page_uri, :previous_page_uri, :next_page_uri, :current_page, :items, :items_count

        def_delegators :@items, :count, :first, :last

        def initialize(params)
            @_client = params['_client']

            @first_page_uri = params['_links']['first'].try(:[], 'href')
            @previous_page_uri = params['_links']['previous'].try(:[], 'href')
            @next_page_uri = params['_links']['next'].try(:[], 'href')
            @current_page = params['current_page']
            @items = params['_embedded']['items'].map do |item|
                Product.new(item.merge({ _client: @_client, _persisted: true }))
            end
            @items_count = params['items_count']
        end

        def each
            if block_given?
                @items.each{|x| yield(x)}
            else
                return @items.each
            end
        end

        def first_page
            @_client.products({ uri: @first_page_uri })
        end

        def next_page
            @_client.products({ uri: @next_page_uri })
        end

        def previous_page
            @_client.products({ uri: @previous_page_uri })
        end
    end
end
