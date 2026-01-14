# RailsRackRetry

A Rack middleware for Rails that provides fallback routing with configurable path prefixes. When a route is not found, the middleware automatically retries the request with a configured prefix, enabling flexible routing configurations for applications mounted under sub-paths or requiring route aliasing.

## Features

- **Automatic Route Fallback**: Intercepts `ActionController::RoutingError` and retries with a prefix
- **Configurable Prefix**: Set any prefix for fallback routes (e.g., `/api`, `/v1`, `/admin`)
- **Logging Support**: Optional logging of retry attempts and failures
- **Rails Integration**: Seamless integration via Railtie
- **Prevent Infinite Loops**: Smart retry logic prevents infinite retry loops
- **Zero Configuration**: Works out of the box with sensible defaults

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_rack_retry'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails_rack_retry
```

## Usage

### Basic Configuration

Add to your Rails application's `config/application.rb`:

```ruby
module YourApp
  class Application < Rails::Application
    # Configure the middleware prefix
    config.rails_rack_retry.prefix = "api"
    
    # Optional: Enable/disable the middleware (default: true)
    config.rails_rack_retry.enabled = true
    
    # Optional: Set a custom logger (default: Rails.logger)
    config.rails_rack_retry.logger = Rails.logger
  end
end
```

### Alternative Configuration

You can also configure the gem in an initializer (`config/initializers/rails_rack_retry.rb`):

```ruby
RailsRackRetry.configure do |config|
  config.prefix = "api"
  config.enabled = true
  config.logger = Rails.logger
end
```

### How It Works

When a request is made to your Rails application:

1. **First Attempt**: The request is processed normally through the Rails router
2. **Route Not Found**: If `ActionController::RoutingError` is raised
3. **Retry with Prefix**: The middleware adds the configured prefix to the path and retries
4. **Success or Failure**: Either the prefixed route is found, or the error is re-raised

#### Example Flow

```
Request: GET /users
↓
Rails Router: No route matches "/users"
↓
Middleware: Retry with prefix
↓
Modified Request: GET /api/users
↓
Rails Router: Route found! → UsersController#index
```

## Use Cases

### 1. API Versioning

Support both versioned and unversioned API endpoints:

```ruby
# config/application.rb
config.rails_rack_retry.prefix = "api/v1"

# Routes
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
    end
  end
end

# Now both work:
# GET /users → retries as → GET /api/v1/users
# GET /api/v1/users → works directly
```

### 2. Mounting Under Sub-paths

Deploy the same application under different sub-paths without code changes:

```ruby
# Production: mounted at /admin
config.rails_rack_retry.prefix = "admin"

# Staging: mounted at /staging/admin
config.rails_rack_retry.prefix = "staging/admin"
```

### 3. Legacy Route Support

Maintain backward compatibility when restructuring routes:

```ruby
# Old routes: /products, /orders
# New routes: /api/products, /api/orders
# Configure prefix "api" to support both old and new routes
config.rails_rack_retry.prefix = "api"
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `prefix` | String | `""` | Path prefix to add when retrying failed routes |
| `enabled` | Boolean | `true` | Enable or disable the middleware |
| `logger` | Logger | `Rails.logger` | Logger instance for retry attempts and failures |

## CLI

The gem includes a simple CLI for version and configuration information:

```bash
# Show version
rails_rack_retry version

# Show help
rails_rack_retry help

# Show current configuration (in Rails app)
rails_rack_retry config
```

## Logging

When a logger is configured, the middleware logs retry attempts and failures:

```
[RailsRackRetry] Route not found for '/users'. Retrying with prefix: '/api/users'
[RailsRackRetry] Retry failed. Original path: '/users', Prefixed path: '/api/users' also not found.
```

## Testing

The gem includes comprehensive RSpec and Cucumber tests.

### Running RSpec Tests

```bash
bundle exec rspec
```

### Running Cucumber Tests

```bash
bundle exec cucumber
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

```bash
# Run tests
bundle exec rspec
bundle exec cucumber

# Run all tests
bundle exec rake

# Install the gem locally
bundle exec rake install
```

## How It Works Internally

The middleware is implemented as a standard Rack middleware that:

1. Wraps the Rails application
2. Catches `ActionController::RoutingError` exceptions
3. Modifies the `PATH_INFO` in the Rack environment
4. Retries the request by calling the application again
5. Uses a flag (`rails_rack_retry.retried`) to prevent infinite loops

### Middleware Stack Position

The middleware is automatically inserted into the Rails middleware stack via a Railtie. It's positioned to catch routing errors before they bubble up to the user.

You can verify its position:

```bash
bin/rails middleware | grep RailsRackRetry
```

## Thread Safety

The middleware is thread-safe. Each request maintains its own environment hash, so concurrent requests do not interfere with each other.

## Performance Considerations

- **Successful Routes**: Zero overhead - requests that match routes on the first attempt are not affected
- **Failed Routes**: One additional routing attempt when a route is not found
- **Failed Retries**: Minimal overhead - the error is re-raised after one retry attempt

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/rails_rack_retry.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by Manus AI.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
