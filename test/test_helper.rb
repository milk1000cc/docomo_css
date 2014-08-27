require 'minitest/autorun'
require 'mocha/mini_test'

Rails = Mocha::Mockery.instance.unnamed_mock
Rails.stubs(:root => File.dirname(__FILE__))

module ActionController
  Base = Mocha::Mockery.instance.unnamed_mock
  Base.stubs(:asset_host => nil)
end
