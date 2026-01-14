# frozen_string_literal: true

require "rails_rack_retry"
require "rack/test"
require "action_controller"

World(Rack::Test::Methods)

# Reset configuration before each scenario
Before do
  RailsRackRetry.reset_configuration!
end
