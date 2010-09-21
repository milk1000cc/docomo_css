require 'test/unit'
require File.join File.dirname(__FILE__), '..', '..', 'lib', 'docomo_css', 'stylesheet'

class DocomoCss::StylesheetTest < Test::Unit::TestCase
  def test_href
    stylesheet = DocomoCss::Stylesheet.new(:href)
    assert_equal :href, stylesheet.href
  end
end
