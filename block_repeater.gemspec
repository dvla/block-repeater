# frozen_string_literal: true

require_relative 'lib/block_repeater/version'

Gem::Specification.new do |spec|
  spec.name          = 'block_repeater'
  spec.version       = BlockRepeater::VERSION
  spec.authors       = ['William Bray']
  spec.email         = ['william.bray@dvla.gov.uk']

  spec.summary       = 'Conditionally repeat a block of code'
  spec.description   = 'Attempt a piece of code a set number of times or until a condition is met'
  spec.homepage      = ''
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://nexus-internal.iep.dvla.gov.uk/nexus/content/groups/gems'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bump', '~> 0.6'
  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
end
