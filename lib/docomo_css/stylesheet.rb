module DocomoCss
  class Stylesheet
    attr_reader :href

    def initialize(href)
      @href = href
    end

    def path
      File.join(Rails.root, 'public', href.gsub(/\?\d+/, ''))
    end
  end
end
