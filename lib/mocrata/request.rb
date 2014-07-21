# encoding: utf-8
#
require 'cgi'
require 'csv'
require 'json'
require 'net/https'

module Mocrata
  # @attr_reader [String] url the request URL
  # @attr_reader [Symbol] format the request format, `:json` or `:csv`
  # @attr_reader [Hash] params the requst params
  #
  class Request
    attr_reader :url, :format, :params

    # Construct a new Request instance
    #
    # @param url [String] the request URL
    # @param format [Symbol] the request format, `:json` or `:csv`
    # @param params [Hash] the requst params
    #
    # @return [Mocrata::Request] the instance
    #
    def initialize(url, format, params = {})
      @url    = url
      @format = format
      @params = params
    end

    # Perform the HTTP GET request
    #
    # @return [Mocrata::Response] the validated response
    #
    def response
      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Accept', content_type)
      request.add_field('X-App-Token', Mocrata.config.app_token)

      response = http.request(request)

      Mocrata::Response.new(response).tap(&:validate!)
    end

    # @return [String] the content type for the specified format
    #
    # @raise [Mocrata::Request::RequestError] if the format is not supported
    #
    def content_type
      Mocrata::CONTENT_TYPES.fetch(format, nil).tap do |type|
        raise RequestError.new("Invalid format: #{format}") unless type
      end
    end

    private

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def soda_params
      @soda_params ||= {}.tap do |soda|
        limit = params.fetch(:per_page, Mocrata.config.per_page)
        page  = params.fetch(:page, 1)

        soda[:$limit]  = limit
        soda[:$offset] = (page - 1) * limit
      end
    end

    def uri
      @uri ||= URI(url).dup.tap do |uri|
        uri.query = self.class.query_string(soda_params)
      end
    end

    class << self
      # Construct a query string from a hash
      #
      # @param hash [Hash] the hash of parmas
      #
      # @return [String] the query string
      #
      def query_string(hash)
        hash.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
      end
    end

    class RequestError < StandardError; end
  end
end
