# encoding: utf-8
#
require 'json'
require 'csv'

module Mocrata
  class Response
    # Construct a new Response instance
    #
    # @param http_response [Net::HTTPResponse] the http response
    #
    # @return [Mocrata::Response] the instance
    #
    def initialize(http_response)
      @http_response = http_response
    end

    # Perform certain checks against the HTTP response and raise an exception
    # if necessary
    #
    # @return [true]
    #
    # @raise [Mocrata::Response::ResponseError] if the response is invalid
    #
    def validate!
      if content_type == :json
        if body.respond_to?(:has_key?) && body.has_key?('error')
          raise ResponseError.new("API error: #{body['message']}")
        end
      end

      true
    end

    # HTTP headers with certain values parsed as JSON
    #
    # @return [Hash] the header keys and values
    #
    def headers
      @headers ||= {}.tap do |result|
        http_response.each_header do |key, value|
          value = JSON.parse(value) if JSON_HEADERS.include?(key)

          result[key] = value
        end
      end
    end

    # The HTTP response body, processed according to content type
    #
    # @return [Array] the parsed body
    #
    def body
      send(content_type)
    end

    private

    # SODA headers that are always encoded as JSON
    JSON_HEADERS = %w(x-soda2-fields x-soda2-types)

    attr_reader :http_response

    def content_type
      type = headers['content-type']

      CONTENT_TYPES.each do |key, value|
        return key if type && type.start_with?(value)
      end

      raise ResponseError.new("Unexpected content type: #{type}")
    end

    def csv
      CSV.parse(http_response.body)[1..-1] # exclude header
    end

    def json
      JSON.parse(http_response.body)
    end

    class ResponseError < StandardError; end
  end
end
