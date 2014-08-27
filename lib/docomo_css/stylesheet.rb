module DocomoCss
  class Stylesheet
    attr_reader :path

    def initialize(href)
      @href = href
      @path = href && path_from_href(href)
    end

    def valid?
      path && FileTest.exist?(path)
    end

    def asset_css
      return nil unless Rails.application.config.assets.prefix

      path, query = extract_path_and_query(@href)
      path = path.sub(/^#{ Rails.application.config.assets.prefix }/, '').
                  sub(/^\//, '')

      asset = Rails.application.assets.
        find_asset(path, :bundle => !body_only?(query))
      asset ? asset.to_s : nil
    end

    private

    def path_from_href(href)
      base_path = href.gsub(ActionController::Base.asset_host.to_s, '').
                       gsub(/\?\d+/, '')
      File.join(Rails.root, 'public', base_path)
    end

    def extract_path_and_query(href)
      if href =~ /(.+)\?(.+)/
        path, query = $1, $2
      else
        path, query = href, ''
      end
      [path, query]
    end

    def body_only?(query)
      query =~ /body=(1|t)/
    end
  end
end
