# encoding: utf-8
#
module Mocrata
  # Provides Mocrata configuration options
  #
  class Configuration
    # The maximum number of rows allowed per request by Socrata
    #
    MAX_PER_PAGE = 1000

    # @attr [String] app_token A Socrata application token
    #
    attr_accessor :app_token

    # @return [Integer] the value of the `per_page` configuration option
    #
    def per_page
      @per_page ||= MAX_PER_PAGE
    end

    # Sets the value of the `per_page` configuration option
    #
    # @param value [Integer] the number of results per page
    #
    # @return [Integer] the value
    #
    # @raise [Mocrata::Configuration::ConfigurationError] if the value is
    #   invalid
    #
    def per_page=(value)
      if value > MAX_PER_PAGE
        message = "Per page #{value} exceeds maximum value of #{MAX_PER_PAGE}"
        fail ConfigurationError, message
      end

      @per_page = value
    end

    class ConfigurationError < StandardError; end
  end
end
