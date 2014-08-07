# encoding: utf-8
#
require 'cgi'
require 'csv'
require 'json'
require 'net/https'

require 'mocrata/version'

module Mocrata
  # @attr_reader [String] url the request URL
  # @attr_reader [Symbol] format the request format, `:json` or `:csv`
  # @attr_reader [Hash] options hash of options
  # @attr_reader [Hash] params the request params
  #
  class Request
    attr_reader :url, :format, :options, :params

    # Construct a new Request instance
    #
    # @param url [String] the request URL
    # @param format [Symbol] the request format, `:json` or `:csv`
    # @param options [optional, Hash] hash of options
    # @param params [optional, Hash] the request params
    #
    # @option options [Integer] :page the page to request
    # @option options [Integer] :per_page the number of rows to return for each
    #   page
    # @option options [true, false] :paginate whether to add pagination params
    # @option options [true, false] :preserve_header whether to preserve CSV
    #   header
    #
    # @return [Mocrata::Request] the instance
    #
    def initialize(url, format, options = {}, params = {})
      @url     = url
      @format  = format
      @options = options
      @params  = params
    end

    # Perform the HTTP GET request
    #
    # @return [Mocrata::Response] the validated response
    #
    def response
      request = Net::HTTP::Get.new(uri.request_uri)

      request['accept']     = content_type
      request['user-agent'] = USER_AGENT

      request.add_field('x-app-token', Mocrata.config.app_token)

      response = http.request(request)

      Mocrata::Response.new(response, response_options).tap(&:validate!)
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

    USER_AGENT = "mocrata/#{Mocrata::VERSION}"
    SODA_PARAM_KEYS = %w(top limit)

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def soda_params
      @soda_params ||= {}.tap do |soda|
        soda.merge!(pagination_params) if paginate?

        SODA_PARAM_KEYS.each do |key|
          if params.has_key?(key.to_sym)
            soda[:"$#{key}"] = params.fetch(key.to_sym)
          end
        end
      end
    end

    def pagination_params
      {}.tap do |result|
        limit = options.fetch(:per_page, Mocrata.config.per_page)
        page  = options.fetch(:page, 1)

        result[:$limit]  = limit
        result[:$offset] = (page - 1) * limit
      end
    end

    def paginate?
      options.fetch(:paginate, false) ||
        options.has_key?(:page) ||
        options.has_key?(:per_page)
    end

    def response_options
      options.keep_if do |key, value|
        Mocrata::Response::OPTIONS.include?(key)
      end
    end

    def uri
      @uri ||= URI(url).tap do |uri|
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
