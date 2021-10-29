# frozen_string_literal: true

require_relative 'lib/solidus_configurable_kits/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_configurable_kits'
  spec.version = SolidusConfigurableKits::VERSION
  spec.authors = ['Martin Meyerhoff']
  spec.email = 'mamhoff@gmail.com'

  spec.summary = 'Configurable Kits for Solidus. A kit is a product comprised of other products.'
  spec.homepage = 'https://github.com/friendlycart/solidus_configurable_kits'
  spec.license = 'GNU General Public License v3'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/friendlycart/solidus_configurable_kits'
  spec.metadata['changelog_uri'] = 'https://github.com/friendlycart/solidus_configurable_kits/blob/master/CHANGELOG.md'

  spec.required_ruby_version = ['>= 2.5', '< 4.0']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'deface'
  spec.add_dependency 'solidus_backend', ['>= 2.0.0', '<= 3.2']
  spec.add_dependency 'solidus_core', ['>= 2.0.0', '<= 3.2']
  spec.add_dependency 'solidus_support', '~> 0.5'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.4'
end
