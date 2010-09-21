module DocomoCss
  class Stylesheet
    attr_reader :href

    def initialize(href)
      @href = href
    end
  end
end
