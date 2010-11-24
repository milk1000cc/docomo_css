require 'test/unit'
require 'rubygems'
require 'mocha'

Rails = Mocha::Mockery.instance.unnamed_mock
Rails.stubs(:root => File.dirname(__FILE__))

module ActionController
  Base = Mocha::Mockery.instance.unnamed_mock
  Base.stubs(:asset_host => nil)
end
