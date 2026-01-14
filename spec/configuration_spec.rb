# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsRackRetry::Configuration do
  describe "#initialize" do
    it "sets default values" do
      config = described_class.new
      expect(config.prefix).to eq("")
      expect(config.logger).to be_nil
      expect(config.enabled).to eq(true)
    end
  end

  describe "#enabled?" do
    it "returns true when enabled is true" do
      config = described_class.new
      config.enabled = true
      expect(config.enabled?).to eq(true)
    end

    it "returns false when enabled is false" do
      config = described_class.new
      config.enabled = false
      expect(config.enabled?).to eq(false)
    end
  end
end

RSpec.describe RailsRackRetry do
  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(RailsRackRetry.configuration).to be_a(RailsRackRetry::Configuration)
    end

    it "returns the same instance on multiple calls" do
      config1 = RailsRackRetry.configuration
      config2 = RailsRackRetry.configuration
      expect(config1).to be(config2)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      expect { |b| RailsRackRetry.configure(&b) }.to yield_with_args(RailsRackRetry.configuration)
    end

    it "allows setting configuration values" do
      RailsRackRetry.configure do |config|
        config.prefix = "api/v1"
        config.enabled = false
      end

      expect(RailsRackRetry.configuration.prefix).to eq("api/v1")
      expect(RailsRackRetry.configuration.enabled).to eq(false)
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration to defaults" do
      RailsRackRetry.configure do |config|
        config.prefix = "custom"
        config.enabled = false
      end

      RailsRackRetry.reset_configuration!

      expect(RailsRackRetry.configuration.prefix).to eq("")
      expect(RailsRackRetry.configuration.enabled).to eq(true)
    end
  end
end
