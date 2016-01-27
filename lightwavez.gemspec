# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightwavez/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "lightwavez"
  spec.version       = Lightwavez::VERSION
  spec.authors       = ["Khash Sajadi"]
  spec.email         = ["khash@sajadi.co.uk"]
  spec.description   = "A simple Ruby gem to control LightwaveRF link"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
