# frozen_string_literal: true

require_relative 'lib/purple_air_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'purple_air_api'
  spec.version       = PurpleAirApi::VERSION
  spec.authors       = ['Dylan Kiselbach']
  spec.email         = ['dylankiselbach@gmail.com']

  spec.summary       = 'This is an library to assist in interacting with the PurpleAir API.'
  spec.description   = 'To use this gem you will need your own read and write key from PurpleAir which can be retrieved
                        by contacting their support team https://www2.purpleair.com/pages/contact-us.'
  spec.homepage      = 'https://github.com/dkiselbach/purple_air_api'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dkiselbach/purple_air_api.'
  spec.metadata['changelog_uri'] = 'https://github.com/dkiselbach/purple_air_api.'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'faraday', '~> 1.3'
  spec.add_dependency 'fast_jsonparser', '~> 0.5'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
