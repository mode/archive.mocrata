# encoding: utf-8
#
require 'spec_helper'

describe Mocrata::Response do
  let :response do
    Mocrata::Response.new(true)
  end

  describe '#validate!' do
    it 'returns true without content type' do
      expect(response).to receive(:content_type).and_return(nil)
      expect(response.validate!).to be true
    end

    it 'returns true with csv content' do
      expect(response).to receive(:content_type).and_return(:csv)
      expect(response.validate!).to be true
    end

    it 'returns true with json array' do
      expect(response).to receive(:content_type).and_return(:json)
      expect(response).to receive(:body).and_return([])
      expect(response.validate!).to be true
    end

    it 'returns true with json array' do
      expect(response).to receive(:content_type).and_return(:json)
      expect(response).to receive(:body).at_least(:once).and_return({})
      expect(response.validate!).to be true
    end

    it 'raises exception with json error' do
      expect(response).to receive(:content_type).and_return(:json)
      expect(response).to receive(:body).at_least(:once).and_return(
        'error'   => true,
        'message' => 'something went wrong')

      expect { response.validate! }.to raise_error(
        Mocrata::Response::ResponseError)
    end
  end

  describe '#content_type' do
    it 'detects csv' do
      expect(response).to receive(:headers).and_return(
        'content-type' => 'text/csv')

      expect(response.send(:content_type)).to eq(:csv)
    end

    it 'detects csv with junk at the end' do
      expect(response).to receive(:headers).and_return(
        'content-type' => 'text/csv; charset=utf-8')

      expect(response.send(:content_type)).to eq(:csv)
    end

    it 'detects json' do
      expect(response).to receive(:headers).and_return(
        'content-type' => 'application/json')

      expect(response.send(:content_type)).to eq(:json)
    end

    it 'raises exception for unrecognized content type' do
      expect(response).to receive(:headers).and_return(
        'content-type' => 'text/html')

      expect { response.send(:content_type) }.to raise_error(
        Mocrata::Response::ResponseError)
    end

    it 'raises exception for absent content type' do
      expect(response).to receive(:headers).and_return({})
      expect { response.send(:content_type) }.to raise_error(
        Mocrata::Response::ResponseError)
    end
  end

  describe '#csv' do
    it 'parses body and excludes header' do
      csv = "\"header1\"\n\"row1\"\n\"row2\""
      expect(response.send(:http_response)).to receive(:body).and_return(csv)
      expect(response.send(:csv)).to eq([['row1'], ['row2']])
    end
  end

  describe '#json' do
    it 'parses body' do
      json = '[{"key1":"val1"}]'
      expect(response.send(:http_response)).to receive(:body).and_return(json)
      expect(response.send(:json)).to eq([{'key1' => 'val1'}])
    end
  end

  describe '#body' do
    it 'returns json' do
      expect(response).to receive(:content_type).and_return(:json)
      expect(response).to receive(:json).and_return([])
      expect(response.body).to eq([])
    end

    it 'returns csv' do
      expect(response).to receive(:content_type).and_return(:csv)
      expect(response).to receive(:csv).and_return([])
      expect(response.body).to eq([])
    end
  end

  describe '#headers' do
    it 'preserves non json headers' do
      expect(response.send(:http_response)).to receive(:each_header)
        .and_yield('x-foo-header', 'foo')
        .and_yield('x-bar-header', 'bar')

      expect(response.headers).to eq(
        'x-foo-header' => 'foo',
        'x-bar-header' => 'bar')
    end

    it 'parses json headers' do
      expect(response.send(:http_response)).to receive(:each_header)
        .and_yield('x-foo-header', 'foo')
        .and_yield('x-soda2-fields', '{"name":"value"}')

      expect(response.headers).to eq(
        'x-foo-header'   => 'foo',
        'x-soda2-fields' => { 'name' => 'value' })
    end
  end
end
