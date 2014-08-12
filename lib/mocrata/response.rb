# encoding: utf-8
#
require 'csv'
require 'json'
require 'rexml/document'

module Mocrata
  # Represents a Socrata API response
  #
  class Response
    OPTIONS = [:preserve_header]

    # Construct a new Response instance
    #
    # @param http_response [Net::HTTPResponse] the http response
    # @param options [Hash] hash of options
    #
    # @option options [true, false] :preserve_header whether to preserve CSV
    #   header
    #
    # @return [Mocrata::Response] the instance
    #
    def initialize(http_response, options = {})
      @http_response = http_response
      @options       = options
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
        if body.respond_to?(:key?) && body.key?('error')
          fail ResponseError, "API error: #{body['message']}"
        end
      end

      fail ResponseError, "Unexpected response code: #{code}" unless code == 200

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

    def code
      http_response.code.to_i
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

    attr_reader :http_response, :options

    def content_type
      type = headers['content-type']

      CONTENT_TYPES.each do |key, value|
        return key if type && type.start_with?(value)
      end

      fail ResponseError, "Unexpected content type: #{type}"
    end

    def csv
      result = CSV.parse(http_response.body)
      result = result[1..-1] unless preserve_header?
      result
    end

    def json
      JSON.parse(http_response.body)
    end

    def xml
      REXML::Document.new(http_response.body)
    end

    def preserve_header?
      options.fetch(:preserve_header, false)
    end

    class ResponseError < StandardError; end
  end
end
