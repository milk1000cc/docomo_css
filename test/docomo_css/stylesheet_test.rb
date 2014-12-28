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

  def test_asset_css
    css = "div.content { background-color: #999 }"
    mock_asset 'mobile/application.css', css

    href = "/assets/mobile/application.css?body=1"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal css, stylesheet.asset_css
  end

  def test_asset_css_without_body_param
    css = "div.content { background-color: #999 }"
    mock_asset 'mobile/application.css', css, bundle: true

    href = "/assets/mobile/application.css"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal css, stylesheet.asset_css
  end

  def test_asset_css_with_digest
    css = "div.content { background-color: #999 }"
    mock_asset 'mobile/application.css', css, digest: true

    href = "/assets/mobile/application-c692ad4e67b1dc0d0ce.css?body=1"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal css, stylesheet.asset_css
  end
end
