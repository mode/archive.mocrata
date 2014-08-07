# encoding: utf-8
#
module Mocrata
  # @attr_reader [String] original the original Socrata dataset URL
  #
  class DatasetUrl
    attr_reader :original

    # Construct a new DatasetUrl instance
    #
    # @param original [String] the original Socrata dataset URL
    #
    # @return [Mocrata::DatasetUrl] the instance
    #
    # @example
    #   url = Mocrata::DatasetUrl.new('http://data.sfgov.org/resource/funx-qxxn')
    #
    def initialize(original)
      @original = original
    end

    # Convert the original URL to a normalized resource URL
    #
    # @return [String] the resource URL
    #
    def to_resource
      @to_resource ||= normalize
    end

    # Convert the original URL to a normalized OData URL
    #
    # @return [String] the OData URL
    #
    def to_odata
      @to_odata ||= normalize.gsub(/\/resource\//, '/OData.svc/')
    end

    # Validate the original URL against the expected Socrata dataset URL
    # pattern
    #
    # @raise [Mocrata::DatasetUrl::InvalidError] if the URL is invalid
    #
    def validate!
      unless original =~ VALID_PATTERN
        raise InvalidError.new("Invalid URL: #{original.inspect}")
      end

      true
    end

    class << self
      # Ensure that a URL has a valid protocol
      #
      # @param url [String] the url with or without protocol
      #
      # @return [String] the url with protocol
      #
      def ensure_protocol(url)
        if url =~ /\A\/\//
          url = "https:#{url}"
        elsif url !~ /\Ahttps?:\/\//
          url = "https://#{url}"
        end

        url
      end

      # Strip explicit format from a given URL if present
      #
      # @param url [String] the url with or without format
      #
      # @return [String] the url without format
      #
      def strip_format(url)
        url.gsub(/\.[a-zA-Z]+\Z/, '')
      end
    end

    private

    VALID_PATTERN = /\/resource\//

    # Normalize a Socrata dataset URL. Ensures https protocol. Removes query
    # string and fragment, if any.
    #
    # @return [String] the normalized URL
    #
    def normalize
      uri = URI(self.class.ensure_protocol(original))

      uri.scheme   = 'https'
      uri.fragment = nil
      uri.query    = nil

      self.class.strip_format(uri.to_s)
    end

    class InvalidError < StandardError; end
  end
end
