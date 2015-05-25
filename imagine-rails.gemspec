# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "imagine/version"

Gem::Specification.new do |spec|
  spec.name          = "imagine-rails"
  spec.version       = Imagine::VERSION
  spec.authors       = ["Richard Taylor"]
  spec.email         = ["moomerman@gmail.com"]
  spec.summary       = "Rails integration for imagine go image processing server"
  spec.homepage      = "https://github.com/moomerman/imagine-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_dependency "rest-client", "~> 1.8"
  spec.add_dependency "activerecord"
  spec.add_dependency "mime-types"
end
