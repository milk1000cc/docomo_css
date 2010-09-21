module DocomoCss
  class Stylesheet
    attr_reader :path

    def initialize(href)
      @path = href && File.join(Rails.root, 'public', href.gsub(/\?\d+/, ''))
    end

    def valid?
      path && FileTest.exist?(path)
    end
  end
end
