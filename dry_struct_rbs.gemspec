# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'dry_struct_rbs'
  spec.version       = '0.1.0'
  spec.authors       = ['Dmitry Sadovnikov']
  spec.email         = ['sadovnikov.js@gmail.com']
  spec.summary       = 'Generate RBS signatures from Dry::Struct classes'
  spec.description   = 'Automatically creates RBS type definitions for Dry::Struct schemas'
  spec.homepage      = 'https://github.com/DmitrySadovnikov/dry_struct_rbs'
  spec.license       = 'MIT'

  spec.executables << 'dry_struct_rbs'
  spec.bindir = 'exe'

  spec.files         = Dir['lib/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'dry-struct', '~> 1.0'
  spec.add_development_dependency 'prism', '~> 1.4.0'
  spec.add_development_dependency 'rbs', '~> 3.0'
  spec.add_dependency 'unparser', '~> 0.6'

  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
