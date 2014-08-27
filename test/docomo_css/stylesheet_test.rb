require 'test_helper'
require File.join File.dirname(__FILE__), '..', '..', 'lib', 'docomo_css', 'stylesheet'

class DocomoCss::StylesheetTest < MiniTest::Test
  def test_css_path
    ActionController::Base.stubs(:asset_host => nil)
    href = "/stylesheets/all.css?1274411517"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal "#{Rails.root}/public/stylesheets/all.css", stylesheet.path
  end

  def test_css_path_with_asset_host
    ActionController::Base.stubs(:asset_host => "http://assets.example.com/")
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
