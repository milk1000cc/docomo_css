$:.push File.expand_path("../lib", __FILE__)
require "docomo_css/version"

Gem::Specification.new do |s|
  s.name = 'docomo_css'
  s.version = DocomoCss::Version
  s.platform = Gem::Platform::RUBY
  s.authors = ["milk1000cc", "Paul McMahon"]
  s.email = 'info@milk1000.cc'
  s.homepage = 'http://www.milk1000.cc/'
  s.summary = 'CSS inliner'
  s.description = 'Inlines CSS so that you can use external CSS with docomo handsets.'

  s.files         = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.rubyforge_project = "galakei"

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency 'nokogiri', ">= 0"
  s.add_dependency 'tiny_css', "~> 0.1.3"
  s.add_dependency 'rails', ">= 3.0.0"
end
