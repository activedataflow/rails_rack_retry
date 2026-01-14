# frozen_string_literal: true

require "rails/railtie"

module RailsRackRetry
  class Railtie < Rails::Railtie
    config.rails_rack_retry = ActiveSupport::OrderedOptions.new

    initializer "rails_rack_retry.configure" do |app|
      # Set configuration from Rails config
      RailsRackRetry.configure do |config|
        config.prefix = app.config.rails_rack_retry.prefix || ""
        config.logger = app.config.rails_rack_retry.logger || Rails.logger
        config.enabled = app.config.rails_rack_retry.enabled != false
      end
    end

    initializer "rails_rack_retry.insert_middleware", after: :load_config_initializers do |app|
      if RailsRackRetry.configuration.enabled?
        # Insert the middleware before the Rails router
        # This ensures we catch routing errors before they bubble up
        app.config.middleware.use(
          RailsRackRetry::Middleware,
          prefix: RailsRackRetry.configuration.prefix,
          logger: RailsRackRetry.configuration.logger
        )
      end
    end
  end
end
