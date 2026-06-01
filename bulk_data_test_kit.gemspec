# frozen_string_literal: true

require_relative 'lib/bulk_data_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'bulk_data_test_kit'
  spec.version       = BulkDataTestKit::VERSION
  spec.authors       = ['Inferno Team']
  spec.summary       = 'Bulk Data Test Kit'
  spec.description   = 'FHIR Bulk Data Access Test Kit'
  spec.homepage      = 'https://github.com/inferno-framework/bulk-data-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'bloomer', '~> 1.0.0'
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'inferno_core', '~> 1.3', '>= 1.3.1'
  spec.add_runtime_dependency 'json-jwt', '~> 1.15.3'
  spec.add_runtime_dependency 'mime-types', '~> 3.4.0'
  spec.add_runtime_dependency 'ndjson', '~> 1.0.0'
  spec.add_runtime_dependency 'rubyzip', '~> 2.3.2'
  spec.add_runtime_dependency 'smart_app_launch_test_kit', '~> 1.0', '>= 1.0.2'
  spec.add_runtime_dependency 'tls_test_kit', '~> 1.0', '>= 1.0.2'
  spec.add_development_dependency 'database_cleaner-sequel', '~> 1.8'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'webmock', '~> 3.11'
  spec.add_development_dependency 'roo', '~> 2.10.1'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets LICENSE`.split("\x0")
  spec.require_paths = ['lib']
  spec.metadata['inferno_test_kit'] = 'true'
end
