# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-14

### Added
- Initial release of rails_rack_retry gem
- Core middleware implementation for fallback routing
- Configuration system with prefix, enabled, and logger options
- Rails Railtie for automatic integration
- CLI tool for version and configuration display
- Comprehensive RSpec test suite
- Cucumber feature tests for behavior verification
- Logging support for retry attempts and failures
- Prevention of infinite retry loops
- Support for flexible prefix configurations (with/without leading/trailing slashes)
- Thread-safe implementation
- Complete documentation and README

### Features
- Automatic route fallback with configurable prefix
- Seamless Rails integration via Railtie
- Zero-configuration default setup
- Support for API versioning use cases
- Support for sub-path mounting use cases
- Legacy route compatibility support

[0.1.0]: https://github.com/yourusername/rails_rack_retry/releases/tag/v0.1.0
