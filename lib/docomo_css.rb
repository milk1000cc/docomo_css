require 'nokogiri'
require 'tiny_css'

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
      return unless controller.response.content_type == 'application/xhtml+xml'
      body = escape_numeric_character_reference controller.response.body
      body = embed_css body
      controller.response.body = unescape_numeric_character_reference body
    end

    def embed_css(body)
      doc = Nokogiri::HTML(body)

      stylesheet_link_node(doc).each do |linknode|
        href = linknode['href'] or next

        next unless FileTest.exist? css_path(href)
        css = TinyCss.new.read(css_path(href))
        embed_pseudo_style(doc, extract_pseudo_style(css))
        embed_style(doc, css)
      end
      doc.to_xhtml :indent => 0
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

    def escape_numeric_character_reference(text)
      text.gsub /&#(\d+);/, 'HTMLCSSINLINERESCAPE\1::::::::'
    end

    def unescape_numeric_character_reference(text)
      text.gsub /HTMLCSSINLINERESCAPE(\d+)::::::::/, '&#\1;'
    end

    def stylesheet_link_node(document)
      document.xpath '//link[@rel="stylesheet"]'
    end

    def css_path(href)
      File.join(Rails.root, 'public', href.gsub(/\?\d+/, ''))
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
  end
end
