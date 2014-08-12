# encoding: utf-8
#
module Mocrata
  # A Mocrata::Dataset instance represents a SODA dataset and provides
  # interfaces for reading its metadata and contents in supported formats.
  #
  class Dataset
    # Construct a new Dataset instance
    #
    # @param original_url [String] valid {http://dev.socrata.com SODA} resource
    #   url
    #
    # @return [Mocrata::Dataset] the instance
    #
    # @example
    #   dataset = Mocrata::Dataset.new('http://data.sfgov.org/resource/funx-qxxn')
    #
    def initialize(original_url)
      @original_url = original_url
    end

    # Iterate through each row of the dataset
    #
    # @param format [optional, Symbol] the format, `:json` or `:csv`
    #
    # @yield [Array<Array>] row of values
    #
    # @example
    #   dataset.each_row(:json) do |row|
    #     # do something with the row
    #   end
    #
    def each_row(format = :json)
      each_page(format) do |page|
        page.each do |row|
          yield row
        end
      end
    end

    # Iterate through each page of the dataset
    #
    # @param format [optional, Symbol] the format, `:json` or `:csv`
    # @param options [optional, Hash] hash of options
    #
    # @option options [Integer] :per_page the number of rows to return for each
    #   page
    # @option options [Integer] :page the first page
    #
    # @yield [Array<Array>] page of rows
    #
    # @example
    #   dataset.each_page(:csv) do |page|
    #     # do something with the page
    #   end
    #
    def each_page(format = :json, options = {})
      page     = options.fetch(:page, 1)
      per_page = options.fetch(:per_page, Mocrata.config.per_page)

      loop do
        rows = get(format, page: page, per_page: per_page).body
        yield rows
        break if rows.size < per_page
        page += 1
      end
    end

    # All rows in the dataset
    #
    # @param format [optional, Symbol] the format, `:json` or `:csv`
    #
    # @return [Array] all rows in the requested format
    #
    def rows(format = :json)
      rows = []
      each_page(format) { |page| rows += page }
      rows
    end

    # The contents of the dataset in JSON format
    #
    # @return [Array<Hash>] the array of rows
    #
    def json
      rows(:json)
    end

    # The contents of the dataset in CSV format
    #
    # @return [Array<Array>] the array of rows
    #
    def csv
      rows(:csv)
    end

    # The parsed header of the dataset in CSV format
    #
    # @return [Array<String>] the array of headers
    #
    def csv_header
      options = { paginate: false, preserve_header: true }
      params  = { limit: 0 }

      Mocrata::Request.new(resource_url, :csv, options, params).response.body[0]
    end

    # Get the HTTP headers associated with the dataset (SODA doesn't support
    #   HEAD requests)
    #
    # @return [Hash] a hash of headers
    #
    def headers
      @headers ||= get(:json, per_page: 0).headers
    end

    # A hash of field names and types from headers
    #
    # @return [Hash] a hash of field names and types
    #
    def fields
      Hash[field_names.zip(field_types)]
    end

    # A parsed representation of the dataset's {http://www.odata.org OData}
    #
    # @return [REXML::Document] a parsed REXML document
    #
    def odata
      @odata ||= Mocrata::Request.new(odata_url, :xml, top: 0).response.body
    end

    # The name of the dataset from OData
    #
    # @return [String] the dataset name
    #
    def name
      odata.root.elements['title'].text
    end

    private

    attr_reader :original_url

    def get(format, params = {})
      Mocrata::Request.new(resource_url, format, params).response
    end

    def url
      @url ||= Mocrata::DatasetUrl.new(original_url)
    end

    def resource_url
      url.to_resource
    end

    def odata_url
      url.to_odata
    end

    def field_names
      headers.fetch('x-soda2-fields', [])
    end

    def field_types
      headers.fetch('x-soda2-types', [])
    end
  end
end
