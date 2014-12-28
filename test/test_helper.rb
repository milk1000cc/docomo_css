require 'minitest/autorun'
require 'mocha/mini_test'
require 'active_support'

Rails = Mocha::Mockery.instance.unnamed_mock
Rails.stubs(
  :root => File.dirname(__FILE__),
  :application => Mocha::Mockery.instance.unnamed_mock)

module ActionController
  Base = Mocha::Mockery.instance.unnamed_mock
  Base.stubs(:asset_host => nil)
end

def mock_asset(path, css, bundle: false, digest: false)
  assets_config = stub('assets_config', prefix: '/assets', digest: digest)
  rails_config = stub('rails_config', assets: assets_config)

  asset = stub('asset', to_s: css)
  assets = stub('assets') do
    expects(:find_asset).with(path, :bundle => bundle).returns(asset)
  end

  Rails.application.stubs :assets => assets, :config => rails_config
end
