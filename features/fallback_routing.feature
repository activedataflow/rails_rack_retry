Feature: Fallback Routing with Prefix
  As a Rails developer
  I want to automatically retry failed routes with a prefix
  So that I can support flexible routing configurations

  Scenario: Route exists without prefix
    Given a Rails application with routes under "api"
    And the route "/users" exists
    And the middleware is configured with prefix "api"
    When a request is made to "/users"
    Then the request should succeed
    And the response should contain "Found: /users"

  Scenario: Route does not exist but exists with prefix
    Given a Rails application with routes under "api"
    And the route "/api/users" exists
    And the route "/users" does not exist
    And the middleware is configured with prefix "api"
    When a request is made to "/users"
    Then the request should succeed
    And the middleware should retry with path "/api/users"

  Scenario: Route does not exist even with prefix
    Given a Rails application with routes under "api"
    And the route "/nonexistent" does not exist
    And the route "/api/nonexistent" does not exist
    And the middleware is configured with prefix "api"
    When a request is made to "/nonexistent"
    Then the request should fail with a routing error

  Scenario: Multiple level prefix
    Given a Rails application with routes under "api/v1"
    And the route "/api/v1/users" exists
    And the route "/users" does not exist
    And the middleware is configured with prefix "api/v1"
    When a request is made to "/users"
    Then the request should succeed
    And the middleware should retry with path "/api/v1/users"

  Scenario: Without middleware
    Given a Rails application with routes under "api"
    And the route "/users" does not exist
    And the middleware is not configured
    When a request is made to "/users"
    Then the request should fail with a routing error
    And the request should not be retried
