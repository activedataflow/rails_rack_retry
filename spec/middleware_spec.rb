# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsRackRetry::Middleware do
  include Rack::Test::Methods

  let(:successful_app) do
    lambda { |env| [200, { "Content-Type" => "text/plain" }, ["Success"]] }
  end

  let(:failing_app) do
    lambda do |env|
      raise ActionController::RoutingError, "No route matches [GET] \"#{env['PATH_INFO']}\""
    end
  end

  let(:conditional_app) do
    lambda do |env|
      if env["PATH_INFO"] == "/api/users"
        [200, { "Content-Type" => "text/plain" }, ["Users found"]]
      else
        raise ActionController::RoutingError, "No route matches [GET] \"#{env['PATH_INFO']}\""
      end
    end
  end

  describe "#call" do
    context "when route is found on first attempt" do
      let(:app) { described_class.new(successful_app, prefix: "api") }

      it "returns the response without retry" do
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
        expect(response[2]).to eq(["Success"])
      end
    end

    context "when route is not found and retry succeeds" do
      let(:app) { described_class.new(conditional_app, prefix: "api") }

      it "retries with prefix and returns success" do
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
        expect(response[2]).to eq(["Users found"])
      end

      it "modifies PATH_INFO with the prefix" do
        env = { "PATH_INFO" => "/users" }
        app.call(env)
        expect(env["PATH_INFO"]).to eq("/api/users")
      end

      it "sets the retry flag" do
        env = { "PATH_INFO" => "/users" }
        app.call(env)
        expect(env["rails_rack_retry.retried"]).to eq(true)
      end

      it "stores the original path" do
        env = { "PATH_INFO" => "/users" }
        app.call(env)
        expect(env["rails_rack_retry.original_path"]).to eq("/users")
      end
    end

    context "when route is not found and retry also fails" do
      let(:app) { described_class.new(failing_app, prefix: "api") }

      it "raises the routing error" do
        expect do
          app.call({ "PATH_INFO" => "/nonexistent" })
        end.to raise_error(ActionController::RoutingError)
      end

      it "does not retry more than once" do
        call_count = 0
        counting_app = lambda do |env|
          call_count += 1
          raise ActionController::RoutingError, "No route"
        end

        middleware = described_class.new(counting_app, prefix: "api")
        
        expect do
          middleware.call({ "PATH_INFO" => "/test" })
        end.to raise_error(ActionController::RoutingError)

        expect(call_count).to eq(2) # Original attempt + 1 retry
      end
    end

    context "with different prefix configurations" do
      it "handles prefix without leading slash" do
        app = described_class.new(conditional_app, prefix: "api")
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
      end

      it "handles prefix with leading slash" do
        app = described_class.new(conditional_app, prefix: "/api")
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
      end

      it "handles prefix with trailing slash" do
        app = described_class.new(conditional_app, prefix: "api/")
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
      end

      it "handles empty prefix" do
        app = described_class.new(successful_app, prefix: "")
        response = app.call({ "PATH_INFO" => "/users" })
        expect(response[0]).to eq(200)
      end
    end

    context "with logger" do
      let(:logger) { double("Logger") }
      let(:app) { described_class.new(conditional_app, prefix: "api", logger: logger) }

      it "logs retry attempts" do
        expect(logger).to receive(:info).with(
          "[RailsRackRetry] Route not found for '/users'. Retrying with prefix: '/api/users'"
        )
        app.call({ "PATH_INFO" => "/users" })
      end

      it "logs retry failures" do
        failing_middleware = described_class.new(failing_app, prefix: "api", logger: logger)
        
        expect(logger).to receive(:info).with(
          "[RailsRackRetry] Route not found for '/test'. Retrying with prefix: '/api/test'"
        )
        expect(logger).to receive(:warn).with(
          "[RailsRackRetry] Retry failed. Original path: '/test', Prefixed path: '/api/test' also not found."
        )

        expect do
          failing_middleware.call({ "PATH_INFO" => "/test" })
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
