# encoding: utf-8
#
require 'spec_helper'

describe Mocrata::Dataset do
  let :dataset do
    Mocrata::Dataset.new('')
  end

  let :rows do
    (0..5).map do |i|
      { "key_#{i}" => "value_#{i}" }
    end
  end

  let :pages do
    [rows[0..3], rows[4..5]]
  end

  describe '#each_row' do
    it 'yields rows' do
      expect(dataset).to receive(:each_page)
        .and_yield(pages[0])
        .and_yield(pages[1])

      expect { |b|
        dataset.each_row(:json, &b)
      }.to yield_successive_args(*rows)
    end
  end

  describe '#each_page' do
    it 'yields pages' do
      response = double(:response)
      expect(response).to receive(:body).and_return(*pages)
      expect(dataset).to receive(:get).and_return(response).at_least(:once)

      expect { |b|
        dataset.each_page(:json, :per_page => 4, &b)
      }.to yield_successive_args(*pages)
    end
  end

  describe '#get' do
    it 'returns response' do
      dataset = Mocrata::Dataset.new(
        'https://data.sfgov.org/resource/funx-qxxn')

      response = Mocrata::Response.new(true)

      expect_any_instance_of(Mocrata::Request).to receive(
        :response).and_return(response)

      expect(dataset.send(:get, :csv)).to eq(response)
    end
  end

  describe '#name' do
    it 'fetches name from odata' do
      dataset = Mocrata::Dataset.new(
        'https://data.sfgov.org/resource/dataset-identifier')

      xml = %{<feed>
      <title type="text">Test name</title>
      <id>http://opendata.socrata.com/OData.svc/dataset-identifier</id>
      <updated>2012-06-15T18:15:19Z</updated>
      </feed>}

      expect(dataset).to receive(:odata).and_return(REXML::Document.new(xml))
      expect(dataset.name).to eq('Test name')
    end
  end

  describe '#odata' do
    it 'returns odata xml document' do
      dataset = Mocrata::Dataset.new(
        'https://data.sfgov.org/resource/funx-qxxn')

      response = Mocrata::Response.new(true)
      expect(response).to receive(:content_type).and_return(:xml)
      expect(response).to receive(:http_response).and_return(
        double(:http_response, :body => ''))
      expect_any_instance_of(Mocrata::Request).to receive(
        :response).and_return(response)

      expect(dataset.odata).to be_an_instance_of(REXML::Document)
    end
  end

  describe '#csv' do
    it 'returns csv body' do
      response = Mocrata::Response.new(true)

      expect(response).to receive(:body).and_return([])
      expect(dataset).to receive(:get).and_return(response)

      expect(dataset.csv).to eq([])
    end
  end

  describe '#csv_header' do
    it 'returns csv header' do
      dataset = Mocrata::Dataset.new(
        'https://data.sfgov.org/resource/funx-qxxn')

      response = double(:response, :body => [['foo', 'bar']])

      expect_any_instance_of(Mocrata::Request).to receive(
        :response).and_return(response)

      expect(dataset.csv_header).to eq(['foo', 'bar'])
    end
  end

  describe '#json' do
    it 'returns json body' do
      response = Mocrata::Response.new(true)

      expect(response).to receive(:body).and_return([])
      expect(dataset).to receive(:get).and_return(response)

      expect(dataset.json).to eq([])
    end
  end

  describe '#headers' do
    it 'builds headers' do
      response = Mocrata::Response.new(true)

      expect(response).to receive(:headers).and_return('foo' => 'bar')
      expect(dataset).to receive(:get).and_return(response)

      expect(dataset.headers).to eq('foo' => 'bar')
    end
  end

  describe '#fields' do
    it 'builds empty map' do
      expect(dataset).to receive(:field_names).and_return([])
      expect(dataset).to receive(:field_types).and_return([])

      expect(dataset.fields).to eq({})
    end

    it 'builds map' do
      expect(dataset).to receive(:field_names).and_return(['key1', 'key2'])
      expect(dataset).to receive(:field_types).and_return(['val1', 'val2'])

      expect(dataset.fields).to eq('key1' => 'val1', 'key2' => 'val2')
    end
  end

  describe '#field_names' do
    it 'handles missing header' do
      expect(dataset).to receive(:headers).and_return({})

      expect(dataset.send(:field_names)).to eq([])
    end

    it 'returns header if present' do
      expect(dataset).to receive(:headers).and_return(
        'x-soda2-fields' => ['name1', 'name2'])

      expect(dataset.send(:field_names)).to eq(['name1', 'name2'])
    end
  end

  describe '#field_types' do
    it 'handles missing header' do
      expect(dataset).to receive(:headers).and_return({})

      expect(dataset.send(:field_types)).to eq([])
    end

    it 'returns header if present' do
      expect(dataset).to receive(:headers).and_return(
        'x-soda2-types' => ['type1', 'type2'])

      expect(dataset.send(:field_types)).to eq(['type1', 'type2'])
    end
  end
end
