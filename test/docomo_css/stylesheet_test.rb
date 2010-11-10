$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require File.expand_path('../../lib/docomo_css/stylesheet', File.dirname(__FILE__))

module ActionController; module Base; def self.asset_host; "http://assets.example.com"; end; end; end
unless defined?(Rails)
  module Rails; def self.root; File.dirname(File.dirname(__FILE__)); end; end
end

class DocomoCss::StylesheetTest < Test::Unit::TestCase
  def test_css_path
    href = "/stylesheets/all.css?1274411517"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal "#{Rails.root}/public/stylesheets/all.css", stylesheet.path
  end

  def test_css_path_with_asset_host
    href = "http://assets.example.com/stylesheets/all.css?1274411517"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal "#{Rails.root}/public/stylesheets/all.css", stylesheet.path
  end

  def test_valid
    assert !DocomoCss::Stylesheet.new(nil).valid?
    assert !DocomoCss::Stylesheet.new("/all.css?1274411517").valid?
    assert DocomoCss::Stylesheet.new("/actual.css?1274411517").valid?
  end
end
