# encoding: utf-8
#
# Mocrata is a [SODA](http://dev.socrata.com/) (Socrata Open Data API) client
# developed by [Mode Analytics](https://modeanalytics.com).
#
module Mocrata
  # Supported Socrata content types
  #
  # @see http://dev.socrata.com/docs/formats/ Socrata format documentation
  #
  CONTENT_TYPES = {
    json: 'application/json',
    csv:  'text/csv',
    xml:  'application/atom+xml'
  }

  class << self
    # Set Mocrata configuration values
    #
    # @yield [Mocrata::Configuration] the configuration instance
    #
    # @example
    #   Mocrata.configure do |config|
    #     config.app_token = 'yourtoken'
    #     config.per_page  = 1000
    #   end
    #
    def configure
      yield config
    end

    # The Mocrata configuration instance
    #
    # @return [Mocrata::Configuration] the configuration instance
    #
    def config
      @config ||= Mocrata::Configuration.new
    end

    # Remove Mocrata configuration instance variable
    #
    def reset
      remove_instance_variable(:@config) if instance_variable_defined?(:@config)
    end
  end
end

require 'mocrata/configuration'
require 'mocrata/dataset'
require 'mocrata/dataset_url'
require 'mocrata/request'
require 'mocrata/response'
require 'mocrata/version'
