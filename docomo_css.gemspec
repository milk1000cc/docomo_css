# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{docomo_css}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["milk1000cc", "Paul McMahon"]
  s.date = %q{2009-06-11}
  s.description = %q{Inlines CSS so that you can use external CSS with docomo handsets.}
  s.email = %q{info@milk1000.cc}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "docomo_css.gemspec",
     "init.rb",
     "install.rb",
     "lib/docomo_css.rb",
     "rails/init.rb",
     "test/docomo_css_test.rb",
     "uninstall.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://www.milk1000.cc/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{CSS inliner}
  s.test_files = [
    "test/docomo_css_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<tiny_css>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<tiny_css>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<tiny_css>, [">= 0"])
  end
end
