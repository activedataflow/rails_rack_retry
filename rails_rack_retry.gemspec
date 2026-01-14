# frozen_string_literal: true

require_relative "lib/rails_rack_retry/version"

Gem::Specification.new do |spec|
  spec.name = "rails_rack_retry"
  spec.version = RailsRackRetry::VERSION
  spec.authors = ["Manus AI"]
  spec.email = ["info@manus.im"]

  spec.summary = "Rack middleware for Rails that provides fallback routing with configurable prefix"
  spec.description = "A Rack middleware that intercepts routing errors in Rails applications and retries the request with a configurable path prefix, enabling flexible route aliasing and sub-path mounting."
  spec.homepage = "https://github.com/yourusername/rails_rack_retry"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yourusername/rails_rack_retry"
  spec.metadata["changelog_uri"] = "https://github.com/yourusername/rails_rack_retry/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rack", ">= 2.0"
  spec.add_dependency "railties", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rack-test", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
