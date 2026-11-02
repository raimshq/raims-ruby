# frozen_string_literal: true

require_relative 'lib/raims/version'

Gem::Specification.new do |spec|
  spec.name = 'raims'
  spec.version = Raims::VERSION
  spec.authors = ['Raims']
  spec.email = ['security@raims.com']
  spec.summary = 'Official Ruby SDK for the Raims public API.'
  spec.description = 'Use the Raims public API from Ruby applications with resource services, cursor pagination, structured errors, and webhook signature verification.'
  spec.homepage = 'https://docs.raims.com/en/integracoes/sdk-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3'
  spec.metadata = {
    'source_code_uri' => 'https://github.com/raimshq/raims-ruby',
    'documentation_uri' => 'https://docs.raims.com/en/integracoes/sdk-ruby',
    'bug_tracker_uri' => 'https://github.com/raimshq/raims-ruby/issues',
    'rubygems_mfa_required' => 'true'
  }
  spec.files = Dir.chdir(__dir__) { Dir['lib/**/*.rb', 'lib/**/*.json', 'LICENSE', 'README.md'] }.sort
  spec.require_paths = ['lib']
  spec.add_dependency 'net-http', '>= 0.4', '< 1'
  spec.add_dependency 'json', '>= 2.19.9', '< 3'
  spec.add_dependency 'bigdecimal', '>= 3.1', '< 5'
  spec.add_dependency 'openssl', '>= 3.2', '< 5'
end
