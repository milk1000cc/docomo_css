require 'docomo_css/filter'

class DocomoCss::Railtie < Rails::Railtie
  initializer "docomo_css.extend.action_controller" do
    ActionController::Base.class_eval do
      def self.docomo_filter
        after_filter DocomoCss::Filter.new
      end
    end
  end
end
