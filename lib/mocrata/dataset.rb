# encoding: utf-8
#
module Mocrata
  # A Mocrata::Dataset instance represents a SODA dataset and provides
  # interfaces for reading its metadata and contents in supported formats.
  #
  class Dataset
    # Construct a new Dataset instance
    #
    # @param url [String] valid {http://dev.socrata.com SODA} resource url
    #
    # @return [Mocrata::Dataset] the instance
    #
    # @example
    #   dataset = Mocrata::Dataset.new('http://data.sfgov.org/resource/funx-qxxn')
    #
    def initialize(url)
      @url = url
    end

    # Iterate through each row of the dataset
    #
    # @param format [Symbol, String] the format, `:json` or `:csv`
    #
    # @yield [Array<Array>] row of values
    #
    # @example
    #   dataset.each_row(:json) do |row|
    #     # do something with the row
    #   end
    #
    def each_row(format, &block)
      each_page(format) do |page|
        page.each(&block)
      end
    end

    # Iterate through each page of the dataset
    #
    # @param format [Symbol, String] the format, `:json` or `:csv`
    # @param per_page [optional, Integer] the number of rows to return for each page
    #
    # @yield [Array<Array>] page of rows
    #
    # @example
    #   dataset.each_page(:csv) do |page|
    #     # do something with the page
    #   end
    #
    def each_page(format, per_page = nil, &block)
      page       = 1
      per_page ||= Mocrata.config.per_page

      while true
        rows = send(format, :page => page, :per_page => per_page)
        yield rows
        break if rows.size < per_page
        page += 1
      end
    end

    # The contents of the dataset in CSV format
    #
    # @param params [optional, Hash] hash of options to pass along to the HTTP request
    #
    # @option params [Integer] :page the page to request
    # @option params [Integer] :per_page the number of rows to return for each page
    #
    # @return [Array<Array>] the array of rows
    #
    # @example
    #   dataset.csv(:page => 2, :per_page => 10)
    #
    def csv(params = {})
      get(:csv, params).body
    end

    # The contents of the dataset in JSON format
    #
    # @param params [optional, Hash] hash of options to pass along to the HTTP request
    #
    # @option params [Integer] :page the page to request
    # @option params [Integer] :per_page the number of rows to return for each page
    #
    # @return [Array<Hash>] the array of rows
    #
    # @example
    #   dataset.json(:page => 2, :per_page => 10)
    #
    def json(params = {})
      get(:json, params).body
    end

    # Get the headers associated with the dataset
    #
    # @return [Hash] a hash of headers
    #
    def headers
      # SODA doesn't support HEAD requests, unfortunately
      @headers ||= get(:json, :per_page => 0).headers
    end

    # A hash of field names and types from headers
    #
    # @return [Hash] a hash of field names and types
    #
    def fields
      Hash[field_names.zip(field_types)]
    end

    private

    attr_reader :url

    def get(format, params = {})
      Mocrata::Request.new(base_url, format, params).response
    end

    def base_url
      @base_url ||= Mocrata::DatasetUrl.new(url).normalize
    end

    def field_names
      headers.fetch('x-soda2-fields', [])
    end

    def field_types
      headers.fetch('x-soda2-types', [])
    end
  end
end
