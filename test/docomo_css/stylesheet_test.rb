require 'test/unit'
require File.join File.dirname(__FILE__), '..', '..', 'lib', 'docomo_css', 'stylesheet'

class DocomoCss::StylesheetTest < Test::Unit::TestCase
  def test_css_path
    href = "/stylesheets/all.css?1274411517"
    stylesheet = DocomoCss::Stylesheet.new(href)
    assert_equal "#{Rails.root}/public/stylesheets/all.css", stylesheet.path
  end

  def test_valid
    assert !DocomoCss::Stylesheet.new(nil).valid?
    assert !DocomoCss::Stylesheet.new("/all.css?1274411517").valid?
    assert DocomoCss::Stylesheet.new("/actual.css?1274411517").valid?
  end
end
