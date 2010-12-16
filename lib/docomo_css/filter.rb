require 'docomo_css/stylesheet'
require 'nokogiri'
require 'tiny_css'

module DocomoCss
  class Filter
    def after(controller)
      return unless controller.response.content_type =~ /application\/xhtml\+xml/
      return unless controller.request.user_agent =~ /docomo/i
      return if docomo_2_0_browser?(controller)
      body = escape_numeric_character_reference controller.response.body
      body = embed_css remove_xml_declare(body)
      controller.response.body = unescape_numeric_character_reference body
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
          # inject support for unsupported styles
          if /h\d/ =~ element.name 
            # font-size needs to be changed in span
            element.children.wrap('<span>')
            element.children.first['style'] = merge_style element['style'], stringified_style

            # background-color should be changed in div to give 100% width
            div = Nokogiri.make("<div>")
            div['style'] = merge_style element['style'], stringified_style
            element.replace(div)
            div.add_child(element)
          else
            element['style'] = merge_style element['style'], stringified_style
          end
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

    def escape_numeric_character_reference(text)
      text.gsub /&#(\d+|x[\da-fA-F]+);/, 'HTMLCSSINLINERESCAPE\1::::::::'
    end

    def unescape_numeric_character_reference(text)
      text.gsub /HTMLCSSINLINERESCAPE(\d+|x[\da-fA-F]+)::::::::/, '&#\1;'
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
