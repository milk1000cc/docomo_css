# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docomo_css/version'

Gem::Specification.new do |spec|
  spec.name          = "docomo_css"
  spec.version       = DocomoCss::VERSION
  spec.authors       = ["milk1000cc", "Paul McMahon"]
  spec.email         = ["info@milk1000.cc"]
  spec.summary       = %q{CSS inliner}
  spec.description   = %q{Inlines CSS so that you can use external CSS with docomo handsets.}
  spec.homepage      = "https://github.com/milk1000cc/docomo_css"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "tiny_css"
  spec.add_dependency "rails"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
