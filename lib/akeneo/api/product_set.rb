module Akeneo::Api
    class ProductSet
        attr_accessor :client, :first_page_uri, :previous_page_uri, :next_page_uri, :current_page, :items

        delegate :count, to: :@items
        delegate :first, to: :@items
        delegate :last, to: :@items

        def initialize(client, params)
            @client = client
            @first_page_uri = params['_links']['first']['href']
            @previous_page_uri = params['_links']['previous'].try(:[], 'href')
            @next_page_uri = params['_links']['next'].try(:[], 'href')
            @current_page = params['current_page']
            @items = params['_embedded']['items'].map do |item|
                Product.new(item)
            end
        end

        def each
            if block_given?
                @items.each{|x| yield(x)}
            else
                return @items.each
            end
        end

        def first_page
            @client.products({ uri: @first_page_uri })
        end

        def next_page
            @client.products({ uri: @next_page_uri })
        end

        def previous_page
            @client.products({ uri: @previous_page_uri })
        end
    end
end