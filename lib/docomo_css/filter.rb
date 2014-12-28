require 'docomo_css/stylesheet'
require 'docomo_css/embeddable_style'
require 'nokogiri'
require 'tiny_css'

ActiveSupport.on_load(:action_controller) do
  def self.docomo_filter(options = {})
    after_action DocomoCss::Filter.new(options)
  end
end

module DocomoCss
  class Filter
    def initialize(options = {})
      @options = { :xml_declare => true, :mobile => false }.merge(options)
    end

    def after(controller)
      return unless controller.response.content_type =~ /application\/xhtml\+xml/
      unless @options[:mobile]
        return unless controller.request.user_agent =~ /docomo/i
        return if docomo_2_0_browser?(controller)
      end
      body = escape_character_reference controller.response.body
      body = embed_css remove_xml_declare(body)
      controller.response.body = unescape_character_reference body
    end

    def embed_css(body)
      doc = Nokogiri::HTML(body)
      if doc.encoding.nil? && head = doc.at("/html/head")
        head.add_child("<!-- Please explicitly specify the encoding of your document as below. Assuming UTF-8. -->")
        head.add_child("<meta content='application/xhtml+xml;charset=UTF-8' http-equiv='content-type' />")
        doc.encoding = "UTF-8"
      end

      stylesheet_link_node(doc).each do |linknode|
        linknode.unlink
        stylesheet = DocomoCss::Stylesheet.new(linknode['href'])
        if stylesheet.valid?
          css = TinyCss.new.read(stylesheet.path)
        else
          css = stylesheet.asset_css
          next unless css
          css = TinyCss.new.read_string(css)
        end
        embed_pseudo_style(doc, extract_pseudo_style(css))
        embed_style(doc, css)
      end

      result = ''
      result << xml_declare(doc) if @options[:xml_declare]
      result << doc.to_xhtml(:indent => 0, :encoding => doc.encoding)
      result
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
        doc.css(selector).each do |element|
          element.embed_style(style)
        end
      end
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
