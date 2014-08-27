require 'nokogiri'

module DocomoCss
  module EmbeddableStyle
    def embed_style(style, options = {})
      options = {:inject_unsupported_styles => true}.merge!(options)
      style = style.dup
      inject_unsupported_styles(style) if options[:inject_unsupported_styles]
      merge_style style
    end

    def merge_style(other_style)
      return if other_style.empty?
      if self['style'] == nil
        self['style'] = other_style.to_s
      else
        self['style'] += ";" unless self['style'] =~ /;\Z/
        self['style'] += other_style.to_s
      end
    end

    private

    def inject_unsupported_styles(style)
      if /^(h\d|p)$/ =~ name
        if (h = style.split('color', 'font-size')) && !h.empty? && !children.empty?
          children.wrap('<span>')
          children.first.merge_style h
        end
        if (h = style.split('background-color', 'background')) && !h.empty? && !children.empty?
          div = Nokogiri.make("<div>")
          div.merge_style(h)
          replace(div)
          div.add_child(self)
        end
      end
    end
  end
end

Nokogiri::XML::Element.send(:include, DocomoCss::EmbeddableStyle)
