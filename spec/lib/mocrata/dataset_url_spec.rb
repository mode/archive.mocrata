# encoding: utf-8
#
require 'spec_helper'

describe Mocrata::DatasetUrl do
  describe '#validate!' do
    it 'returns true for valid url' do
      url = Mocrata::DatasetUrl.new(
        'data.sfgov.org/resource/funx-qxxn.csv?limit=100#foo')

      expect(url.validate!).to eq(true)
    end

    it 'raises exception for invalid url' do
      url = Mocrata::DatasetUrl.new('data.sfgov.org/nope/funx-qxxn.csv')

      expect {
        url.validate!
      }.to raise_error(Mocrata::DatasetUrl::InvalidError)
    end
  end

  describe '#normalize' do
    it 'normalizes original url' do
      url = Mocrata::DatasetUrl.new(
        'data.sfgov.org/resource/funx-qxxn.csv?limit=100#foo')

      expect(url.send(:normalize)).to eq(
        'https://data.sfgov.org/resource/funx-qxxn')
    end
  end

  describe '.ensure_protocol' do
    it 'adds missing protocol' do
      url = Mocrata::DatasetUrl.ensure_protocol('data.sfgov.org/')

      expect(url).to eq('https://data.sfgov.org/')
    end

    it 'adds protocol to schemeless url' do
      url = Mocrata::DatasetUrl.ensure_protocol('//data.sfgov.org/')

      expect(url).to eq('https://data.sfgov.org/')
    end

    it 'preserves http protocol' do
      url = Mocrata::DatasetUrl.ensure_protocol('http://data.sfgov.org/')

      expect(url).to eq('http://data.sfgov.org/')
    end

    it 'preserves https protocol' do
      url = Mocrata::DatasetUrl.ensure_protocol('https://data.sfgov.org/')

      expect(url).to eq('https://data.sfgov.org/')
    end
  end

  describe '.strip_format' do
    it 'preserves url without format' do
      url = Mocrata::DatasetUrl.strip_format('data.sfgov.org/resource/foo')

      expect(url).to eq('data.sfgov.org/resource/foo')
    end

    it 'strips format at end of url' do
      url = Mocrata::DatasetUrl.strip_format('data.sfgov.org/resource/foo.bar')

      expect(url).to eq('data.sfgov.org/resource/foo')
    end

    it 'preserves format if not at end of url' do
      url = Mocrata::DatasetUrl.strip_format('data.sfgov.org/resource/foo.bar/baz')

      expect(url).to eq('data.sfgov.org/resource/foo.bar/baz')
    end
  end
end
