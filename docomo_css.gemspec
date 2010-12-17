require File.expand_path("../lib/docomo_css/version", __FILE__)

Gem::Specification.new do |s|
  s.name = 'docomo_css'
  s.version = DocomoCss::Version
  s.platform = Gem::Platform::RUBY
  s.authors = ["milk1000cc", "Paul McMahon"]
  s.email = 'info@milk1000.cc'
  s.homepage = 'http://www.milk1000.cc/'
  s.summary = 'CSS inliner'
  s.description = 'Inlines CSS so that you can use external CSS with docomo handsets.'

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "docomo_css"

  s.files = Dir["MIT-LICENSE", "README.rdoc", "lib/**/*"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = "lib"

  s.add_dependency 'nokogiri', ">= 0"
  s.add_dependency 'tiny_css', "~> 0.1.0"
  s.add_dependency 'rails', ">= 3.0.0"
end
