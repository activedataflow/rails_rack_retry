# frozen_string_literal: true

Given("a Rails application with routes under {string}") do |prefix|
  @prefix = prefix
  @routes = {}
end

Given("the route {string} exists") do |route|
  @routes[route] = true
end

Given("the route {string} does not exist") do |route|
  @routes[route] = false
end

Given("the middleware is configured with prefix {string}") do |prefix|
  @middleware_prefix = prefix
  
  # Create a mock Rails app that checks routes
  @rails_app = lambda do |env|
    path = env["PATH_INFO"]
    if @routes[path]
      [200, { "Content-Type" => "text/plain" }, ["Found: #{path}"]]
    else
      raise ActionController::RoutingError, "No route matches [GET] \"#{path}\""
    end
  end
  
  # Wrap with our middleware
  @app = RailsRackRetry::Middleware.new(@rails_app, prefix: @middleware_prefix)
end

When("a request is made to {string}") do |path|
  @request_path = path
  begin
    @response = @app.call({ "PATH_INFO" => path })
    @error = nil
  rescue ActionController::RoutingError => e
    @error = e
    @response = nil
  end
end

Then("the request should succeed") do
  expect(@error).to be_nil
  expect(@response).not_to be_nil
  expect(@response[0]).to eq(200)
end

Then("the request should fail with a routing error") do
  expect(@error).not_to be_nil
  expect(@error).to be_a(ActionController::RoutingError)
end

Then("the middleware should retry with path {string}") do |expected_path|
  # This is implicitly tested by the success of the request
  # If the retry didn't happen with the correct path, the request would fail
  expect(@response).not_to be_nil
  expect(@response[2]).to eq(["Found: #{expected_path}"])
end

Then("the response should contain {string}") do |expected_content|
  expect(@response).not_to be_nil
  expect(@response[2].join).to include(expected_content)
end

Given("the middleware is not configured") do
  @app = lambda do |env|
    path = env["PATH_INFO"]
    if @routes[path]
      [200, { "Content-Type" => "text/plain" }, ["Found: #{path}"]]
    else
      raise ActionController::RoutingError, "No route matches [GET] \"#{path}\""
    end
  end
end

Then("the request should not be retried") do
  # Without middleware, the error should be raised immediately
  expect(@error).not_to be_nil
end
