# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'code_changelog/version'

Gem::Specification.new do |spec|
  spec.name          = "code_changelog"
  spec.version       = CodeChangelog::VERSION
  spec.authors       = ["Alexis François"]
  spec.email         = ["alexis.francois.eu@gmail.com"]
  spec.description   = ''
  spec.summary       = ''
  spec.homepage      = ''
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
