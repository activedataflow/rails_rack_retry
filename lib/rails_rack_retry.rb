# frozen_string_literal: true

require_relative "rails_rack_retry/version"
require_relative "rails_rack_retry/configuration"
require_relative "rails_rack_retry/middleware"

# Load Railtie if Rails is available
if defined?(Rails)
  require_relative "rails_rack_retry/railtie"
end

module RailsRackRetry
  class Error < StandardError; end
end
