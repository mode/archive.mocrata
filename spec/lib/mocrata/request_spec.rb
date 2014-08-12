# encoding: utf-8
#
require 'spec_helper'

describe Mocrata::Request do
  describe '#response' do
    it 'forms response' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', :json)

      expect_any_instance_of(Mocrata::Response).to receive(
        :validate!).and_return(true)

      expect(request.send(:http)).to receive(:request).and_return(true)

      expect(request.response).to be_an_instance_of(Mocrata::Response)
    end
  end

  describe '#content_type' do
    it 'raises exception with null format' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil)

      expect {
        request.content_type
      }.to raise_error(Mocrata::Request::RequestError)
    end

    it 'raises exception with invalid format' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', :nope)

      expect {
        request.content_type
      }.to raise_error(Mocrata::Request::RequestError)
    end

    it 'returns valid content type' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', :csv)

      expect(request.content_type).to eq('text/csv')
    end
  end

  describe '#http' do
    it 'uses ssl' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil)

      expect(request.send(:http).use_ssl?).to be true
    end
  end

  describe '#soda_params' do
    describe 'with pagination' do
      it 'has default params' do
        request = Mocrata::Request.new('', nil, paginate: true)

        result = request.send(:soda_params)

        expect(result).to eq(:$limit => 1000, :$offset => 0)
      end

      it 'has custom params' do
        request = Mocrata::Request.new('', nil, paginate: true, page: 2)

        result = request.send(:soda_params)

        expect(result).to eq(:$limit => 1000, :$offset => 1000)
      end
    end

    describe 'without pagination' do
      it 'is empty by default' do
        request = Mocrata::Request.new('', nil)

        expect(request.send(:soda_params)).to eq({})
      end
    end

    it 'ignores unrecognized parameters' do
      request = Mocrata::Request.new('', nil, {}, foo: 'bar', top: 0)

      expect(request.send(:soda_params)).to eq(:$top => 0)
    end
  end

  describe '#pagination_params' do
    it 'is formed with default pagination options' do
      request = Mocrata::Request.new('', nil, paginate: true)

      result = request.send(:pagination_params)

      expect(result).to eq(:$limit => 1000, :$offset => 0)
    end

    it 'is formed with custom pagination options' do
      request = Mocrata::Request.new('', nil, page: 5, per_page: 100)

      result = request.send(:pagination_params)

      expect(result).to eq(:$limit => 100, :$offset => 400)
    end
  end

  describe '#paginate?' do
    it 'is false by default' do
      request = Mocrata::Request.new('', nil)

      expect(request.send(:paginate?)).to eq(false)
    end

    it 'allows override' do
      request = Mocrata::Request.new('', nil, paginate: true)

      expect(request.send(:paginate?)).to eq(true)
    end

    it 'is true if page option is present' do
      request = Mocrata::Request.new('', nil, page: 1)

      expect(request.send(:paginate?)).to eq(true)
    end

    it 'is true if per_page option is present' do
      request = Mocrata::Request.new('', nil, per_page: 1)

      expect(request.send(:paginate?)).to eq(true)
    end
  end

  describe '#response_options' do
    it 'is empty by default' do
      request = Mocrata::Request.new('', nil)

      expect(request.send(:response_options)).to eq({})
    end

    it 'filters request options' do
      request = Mocrata::Request.new('', nil, page: 1, preserve_header: true)

      expect(request.send(:response_options)).to eq(preserve_header: true)
    end
  end

  describe '#uri' do
    before :each do
      expect(Mocrata.config).to receive(:per_page).and_return(10)
    end

    it 'is formed with default parameters' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil, paginate: true)

      result = request.send(:uri).to_s

      expect(result).to eq(
        'https://data.sfgov.org/resource/funx-qxxn?$limit=10&$offset=0')
    end

    it 'is formed with custom parameters' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil,
        per_page: 5,
        page:     3,
        paginate: true)

      result = request.send(:uri).to_s

      expect(result).to eq(
        'https://data.sfgov.org/resource/funx-qxxn?$limit=5&$offset=10')
    end
  end

  describe '.query_string' do
    it 'forms empty query string' do
      expect(Mocrata::Request.query_string({})).to eq('')
    end

    it 'forms simple query string' do
      result = Mocrata::Request.query_string(foo: 'bar')
      expect(result).to eq('foo=bar')
    end

    it 'forms complex string' do
      result = Mocrata::Request.query_string(foo: 'bar', bar: 'baz')
      expect(result).to eq('foo=bar&bar=baz')
    end

    it 'escapes values' do
      result = Mocrata::Request.query_string(foo: '"\'Stop!\' said Fred"')

      expect(result).to eq('foo=%22%27Stop%21%27+said+Fred%22')
    end
  end
end
