# frozen_string_literal: true

require "rails_rack_retry"

module RailsRackRetry
  class CLI
    def self.start(args)
      command = args[0]
      
      case command
      when "version", "-v", "--version"
        puts "rails_rack_retry version #{RailsRackRetry::VERSION}"
      when "help", "-h", "--help", nil
        show_help
      when "config"
        show_config
      else
        puts "Unknown command: #{command}"
        puts "Run 'rails_rack_retry help' for usage information"
        exit 1
      end
    end

    def self.show_help
      puts <<~HELP
        rails_rack_retry - Rack middleware for Rails fallback routing

        Usage:
          rails_rack_retry [command]

        Commands:
          version       Show version information
          config        Show current configuration
          help          Show this help message

        Configuration:
          Add to your Rails application's config/application.rb:

            # Enable the middleware
            config.rails_rack_retry.prefix = "api"
            config.rails_rack_retry.enabled = true
            config.rails_rack_retry.logger = Rails.logger

          Or configure in an initializer (config/initializers/rails_rack_retry.rb):

            RailsRackRetry.configure do |config|
              config.prefix = "api"
              config.enabled = true
              config.logger = Rails.logger
            end

        Example:
          When a route is not found, the middleware will retry with the prefix:
          
          Request: GET /users
          Not found, retrying with: GET /api/users

        Documentation:
          https://github.com/yourusername/rails_rack_retry
      HELP
    end

    def self.show_config
      if defined?(Rails)
        config = RailsRackRetry.configuration
        puts "Current Configuration:"
        puts "  Prefix: #{config.prefix.inspect}"
        puts "  Enabled: #{config.enabled}"
        puts "  Logger: #{config.logger.class.name if config.logger}"
      else
        puts "Rails is not loaded. Configuration is only available in a Rails application."
      end
    end
  end
end
