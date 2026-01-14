# frozen_string_literal: true

module RailsRackRetry
  class Configuration
    attr_accessor :prefix, :logger, :enabled

    def initialize
      @prefix = ""
      @logger = nil
      @enabled = true
    end

    def enabled?
      @enabled == true
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
