require 'minitest/autorun'
require 'mocha/mini_test'

Rails = Mocha::Mockery.instance.unnamed_mock
Rails.stubs(
  :root => File.dirname(__FILE__),
  :application => Mocha::Mockery.instance.unnamed_mock)

module ActionController
  Base = Mocha::Mockery.instance.unnamed_mock
  Base.stubs(:asset_host => nil)
end

def mock_asset(path, bundle, css)
  config = stub('config', :assets => stub('assets_conf', :prefix => '/assets'))
  asset = stub('asset', to_s: css)
  assets = stub('assets') do
    expects(:find_asset).with(path, :bundle => bundle).returns(asset)
  end
  Rails.application.stubs :assets => assets, :config => config
end
