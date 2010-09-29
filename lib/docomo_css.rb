require 'nokogiri'
require 'tiny_css'
require 'docomo_css/stylesheet'

module DocomoCss

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def docomo_filter
      after_filter DocomoCssFilter.new
    end
  end

  class DocomoCssFilter
    def after(controller)
      return unless controller.response.content_type =~ /application\/xhtml\+xml/
      return unless controller.request.user_agent =~ /docomo/i
      return if docomo_2_0_browser?(controller)
      body = escape_character_reference controller.response.body
      body = embed_css remove_xml_declare(body)
      controller.response.body = unescape_character_reference body
    end

    def embed_css(body)
      doc = Nokogiri::HTML(body)

      stylesheet_link_node(doc).each do |linknode|
        stylesheet = DocomoCss::Stylesheet.new(linknode['href'])
        next unless stylesheet.valid?
        css = TinyCss.new.read(stylesheet.path)
        embed_pseudo_style(doc, extract_pseudo_style(css))
        embed_style(doc, css)
      end
      xml_declare(doc) + doc.to_xhtml(:indent => 0, :encoding => doc.encoding)
    end

    def xml_declare(doc)
      <<-XML
<?xml version="1.0" encoding="#{doc.encoding}"?>
      XML
    end

    def remove_xml_declare(body)
      body.gsub(%r'<\?xml[^\?]*?\?>', '')
    end

    def embed_style(doc, css)
      css.style.each do |selector, style|
        stringified_style = stringify_style(style)
        doc.css(selector).each do |element|
          element['style'] = merge_style element['style'], stringified_style
        end
      end
    end

    def stringify_style(style)
      style.map { |k, v| "#{ k }:#{ v }" }.join ';'
    end

    def merge_style(style, other_style)
      return other_style if style == nil
      style += ";" unless style =~ /;\Z/
      style + other_style
    end

    def escape_character_reference(text)
      text.gsub /&(#?[\da-zA-Z]+);/, 'HTMLCSSINLINERESCAPE\1::::::::'
    end

    def unescape_character_reference(text)
      text.gsub /HTMLCSSINLINERESCAPE(#?[\da-zA-Z]+)::::::::/, '&\1;'
    end

    def stylesheet_link_node(document)
      document.xpath '//link[@rel="stylesheet"]'
    end

    def css_path(stylesheet)
      stylesheet.path
    end

    def extract_pseudo_style(css)
      pseudo_style = TinyCss.new
      pseudo_selectors(css).each do |v|
        pseudo_style.style[v] = css.style[v]
        css.style.delete(v)
      end
      pseudo_style
    end

    def embed_pseudo_style(doc, pseudo_style)
      return if pseudo_style.style.keys.empty?

      raise unless doc.at('/html/head')
      doc.at('/html/head').add_child <<-STYLE
<style type="text/css">
#{pseudo_style.write_string}
</style>
      STYLE
      doc
    end

    def pseudo_selectors(css)
      css.style.keys.grep(/a:(link|focus|visited)/)
    end

    private

    def docomo_2_0_browser?(controller)
      controller.request.user_agent =~ /DoCoMo\/2\.0 [^(]*\(c(\d+);/ && $1.to_i >= 500
    end
  end
end
