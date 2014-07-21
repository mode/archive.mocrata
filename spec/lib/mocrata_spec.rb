# encoding: utf-8
#
require 'spec_helper'

describe Mocrata do
  after :each do
    Mocrata.reset
  end

  describe '.configure' do
    it 'sets configuration variables' do
      expect_any_instance_of(Mocrata::Configuration).to receive(:setting=).once

      Mocrata.configure do |config|
        config.setting = 'value'
      end
    end
  end

  describe '.config' do
    it 'instantiates and memoizes configuration instance' do
      expect(Mocrata.instance_variable_get(:@config)).to be_nil

      expect(Mocrata.config).to be_an_instance_of(Mocrata::Configuration)

      config = Mocrata.instance_variable_get(:@config)

      expect(config).to be_an_instance_of(Mocrata::Configuration)
    end
  end
end
