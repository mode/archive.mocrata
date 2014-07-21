# encoding: utf-8
#
require 'spec_helper'

describe Mocrata::Configuration do
  let :config do
    Mocrata::Configuration.new
  end

  describe '#per_page' do
    it 'has default value' do
      expect(config.per_page).to eq(1000)
    end
  end

  describe '#per_page=' do
    it 'overrides default value' do
      expect(config.per_page).to eq(1000)
      config.per_page = 50
      expect(config.per_page).to eq(50)
    end

    it 'raises exception if max value is exceeded' do
      expect { config.per_page = 1001 }.to raise_error(
        Mocrata::Configuration::ConfigurationError)
    end
  end
end
