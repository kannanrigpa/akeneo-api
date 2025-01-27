require 'active_support/core_ext/object/try'

module Akeneo::Api::ClientEndpoint
  class Abstract
    attr_accessor :_params

    def initialize(_client)
      @_client = _client
      @_params = {}
    end

    def self::entityClass
      raise NotImplementedError
    end

    def self::url
      raise NotImplementedError
    end

    def url
      return self.class.url
    end

    def new(params = {})
      return self.class.entityClass.new(params.merge({
        _client: @_client,
        _loaded: true
        }))
    end

    def call(uri, type = Net::HTTP::Get, params = {}, body = {})
      call_uri = URI(uri)
      call_uri.query = URI.encode_www_form(params) if (!params.empty?)

      query = type.new(call_uri)
      query.content_type = 'application/json'
      query['authorization'] = 'Bearer ' + @_client.access_token
      query.body = JSON.generate(body)

      res = Net::HTTP.start(call_uri.hostname, call_uri.port, use_ssl: true) do |http|
        http.request(query)
      end

      if (!res.kind_of? Net::HTTPSuccess) then
        raise Akeneo::Api::QueryException.new(res.body)
      elsif (res.kind_of? Net::HTTPNoContent) then
        return nil
      elsif (res.kind_of? Net::HTTPCreated) then
        return true
      end

      return JSON.parse(res.body)
    end

    def find(unique_identifier)
      begin
        result = call("#{@_client.uri}/api/rest/v1/#{self.url}/#{unique_identifier}")

        return self.class.entityClass.new_from_api(@_client, result)
      rescue Akeneo::Api::QueryException => e
        if e.code == 404 then
          return nil
        else
          raise e
        end
      end
    end

    def save(entity)
      if (!entity._persisted) then
        call(
          "#{@_client.uri}/api/rest/v1/#{self.url}",
          Net::HTTP::Post,
          {},
          entity.to_api
          )
        entity._persisted = true
      else
        call(
          "#{@_client.uri}/api/rest/v1/#{self.url}/#{entity.unique_identifier}",
          Net::HTTP::Patch,
          {},
          entity.to_api
          )
      end
    end

    def limit(limit)
      @_params[:limit] = limit

      return self
    end

    def first
      limit(1);

      result = call(
        "#{@_client.uri}/api/rest/v1/#{self.url}",
        Net::HTTP::Get,
        @_params
        )

      first_result = result['_embedded']['items'][0];

      return nil if first_result.nil?

      return self.class.entityClass.new_from_api(@_client, first_result)
    end

    def each
      raise "This method can not be used without block." if !block_given?

      results = []
      response = call(
        "#{@_client.uri}/api/rest/v1/#{self.url}",
        Net::HTTP::Get,
        @_params
        )

      continue = true
      while (continue)
        response['_embedded']['items'].each do |item|
          entity = self.class.entityClass.new_from_api(@_client, item)
          results.push(entity)

          yield(entity)
        end

        next_page_uri = response['_links']['next'].try(:[], 'href')
        if next_page_uri.nil?
          continue = false
        else
          response = call(next_page_uri)
        end
      end

      return results
    end

    def detect
      each do |entity|
        return entity if yield(entity)
      end

      return nil
    end

    def all
      return each{}
    end

    def map
      results = all

      return results.map do |entity|
        yield(entity)
      end
    end

    def count
      result = 0

      response = call(
        "#{@_client.uri}/api/rest/v1/#{self.url}",
        Net::HTTP::Get,
        @_params
        )

      continue = true
      while (continue)
        result += response['_embedded']['items'].count

        next_page_uri = response['_links']['next'].try(:[], 'href')
        if next_page_uri.nil?
          continue = false
        else
          response = call(next_page_uri)
        end
      end

      return result
    end

    def items_count
      @_params[:with_count] = true

      result = call(
        "#{@_client.uri}/api/rest/v1/#{self.url}",
        Net::HTTP::Get,
        @_params
        )

      return result['items_count'];
    end

    def empty?
      return first.nil?
    end
  end
end
