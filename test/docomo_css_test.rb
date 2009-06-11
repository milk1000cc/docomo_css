require 'test/unit'
require 'rubygems'
require 'action_controller'
require File.join(File.dirname(__FILE__), '..', 'lib', 'docomo_css')

class TestController < ActionController::Base
  include DocomoCss
  docomo_filter
end

class DocomoCssTest < Test::Unit::TestCase
  def test_dependencies
    assert true
  end
end
