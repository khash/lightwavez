# coding: utf-8
lib = File.expand_path('./lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require './lib/version'

Gem::Specification.new do |spec|
  spec.name          = "lightwavez"
  spec.version       = Lightwavez::VERSION
  spec.authors       = ["Khash Sajadi"]
  spec.email         = ["khash@sajadi.co.uk"]
  spec.summary       = "A simple Ruby gem to control LightwaveRF link"
  spec.description   = "This is a quick and simple ruby client gem for LightwaveRF link. No liability is accepted etc etc."
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*")
  spec.require_paths = ["lib"]
end
