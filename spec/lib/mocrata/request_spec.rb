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
    it 'is formed with default params' do
      request = Mocrata::Request.new('', nil)

      expect(request.send(:soda_params)).to eq(:$limit => 1000, :$offset => 0)
    end

    it 'is formed with custom params' do
      request = Mocrata::Request.new('', nil, :page => 5, :per_page => 100)

      expect(request.send(:soda_params)).to eq(:$limit => 100, :$offset => 400)
    end

    it 'ignores custom params' do
      request = Mocrata::Request.new('', nil, :wat => 'nope')

      expect(request.send(:soda_params)).to eq(:$limit => 1000, :$offset => 0)
    end
  end

  describe '#uri' do
    before :each do
      expect(Mocrata.config).to receive(:per_page).and_return(10)
    end

    it 'is formed with default parameters' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil)

      result = request.send(:uri).to_s

      expect(result).to eq(
        'https://data.sfgov.org/resource/funx-qxxn?$limit=10&$offset=0')
    end

    it 'is formed with custom parameters' do
      request = Mocrata::Request.new(
        'https://data.sfgov.org/resource/funx-qxxn', nil,
        :per_page => 5,
        :page     => 3)

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
      result = Mocrata::Request.query_string(:foo => 'bar')
      expect(result).to eq('foo=bar')
    end

    it 'forms complex string' do
      result = Mocrata::Request.query_string(:foo => 'bar', :bar => 'baz')
      expect(result).to eq('foo=bar&bar=baz')
    end

    it 'escapes values' do
      result = Mocrata::Request.query_string(:foo => '"\'Stop!\' said Fred"')

      expect(result).to eq('foo=%22%27Stop%21%27+said+Fred%22')
    end
  end
end
