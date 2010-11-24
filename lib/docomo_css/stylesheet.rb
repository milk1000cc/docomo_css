module DocomoCss
  class Stylesheet
    attr_reader :path

    def initialize(href)
      @path = href && path_from_href(href)
    end

    def valid?
      path && FileTest.exist?(path)
    end

    private

    def path_from_href(href)
      base_path = href.gsub(ActionController::Base.asset_host.to_s, '').
                       gsub(/\?\d+/, '')
      File.join(Rails.root, 'public', base_path)
    end
  end
end
