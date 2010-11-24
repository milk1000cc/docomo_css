class DocomoCss::Railtie < Rails::Railtie
  initializer "docomo_css.extend.action_controller" do
    ActionController::Base.send :include, DocomoCss
  end
end
