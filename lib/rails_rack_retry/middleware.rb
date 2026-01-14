# frozen_string_literal: true

module RailsRackRetry
  class Middleware
    RETRY_FLAG = "rails_rack_retry.retried"
    ORIGINAL_PATH = "rails_rack_retry.original_path"

    def initialize(app, options = {})
      @app = app
      @prefix = options[:prefix] || ""
      @logger = options[:logger]
    end

    def call(env)
      begin
        response = @app.call(env)
        response
      rescue ActionController::RoutingError => e
        handle_routing_error(env, e)
      end
    end

    private

    def handle_routing_error(env, error)
      if already_retried?(env)
        log_retry_failure(env)
        raise error
      else
        retry_with_prefix(env)
      end
    end

    def already_retried?(env)
      env[RETRY_FLAG] == true
    end

    def retry_with_prefix(env)
      # Mark that we've attempted a retry
      env[RETRY_FLAG] = true
      
      # Store the original path for logging
      env[ORIGINAL_PATH] = env["PATH_INFO"].dup
      
      # Add prefix to the path
      original_path = env["PATH_INFO"]
      prefixed_path = build_prefixed_path(original_path)
      env["PATH_INFO"] = prefixed_path
      
      log_retry_attempt(env, original_path, prefixed_path)
      
      # Retry the request with the modified path
      @app.call(env)
    end

    def build_prefixed_path(path)
      # Ensure prefix starts with / and doesn't end with /
      normalized_prefix = @prefix.to_s.strip
      normalized_prefix = "/#{normalized_prefix}" unless normalized_prefix.start_with?("/")
      normalized_prefix = normalized_prefix.chomp("/")
      
      # Ensure path starts with /
      normalized_path = path.start_with?("/") ? path : "/#{path}"
      
      # Combine prefix and path
      "#{normalized_prefix}#{normalized_path}"
    end

    def log_retry_attempt(env, original_path, prefixed_path)
      return unless @logger

      @logger.info(
        "[RailsRackRetry] Route not found for '#{original_path}'. " \
        "Retrying with prefix: '#{prefixed_path}'"
      )
    end

    def log_retry_failure(env)
      return unless @logger

      original_path = env[ORIGINAL_PATH]
      current_path = env["PATH_INFO"]
      @logger.warn(
        "[RailsRackRetry] Retry failed. Original path: '#{original_path}', " \
        "Prefixed path: '#{current_path}' also not found."
      )
    end
  end
end
