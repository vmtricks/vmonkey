# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vmonkey/version'

Gem::Specification.new do |spec|
  spec.name          = 'vmonkey'
  spec.version       = Vmonkey::VERSION
  spec.authors       = ['Brian Dupras', 'Dave Smith', 'Derek Schultz']
  spec.email         = ['brian@duprasville.com', 'dsmith@rallydev.com', 'dschultz@rallydev.com']
  spec.summary       = %q{ Simple to use vsphere methods }
  spec.description   = %q{ Simple to use vsphere methods }
  spec.homepage      = 'https://github.com/vmtricks/vmonkey'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'rbvmomi', '~> 1.5'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'rspec-its'
end
