require 'test_helper'
require File.join File.dirname(__FILE__), '..', '..', 'lib', 'docomo_css', 'filter'

class DocomoCss::FilterTest < Test::Unit::TestCase
  def setup
    @filter = DocomoCss::Filter.new
  end

  def test_invalid_response_content_type
    response = mock("invalid_response") do
      expects(:content_type).returns('text/html').once
      expects(:body).never
    end
    controller = stub("invalid_controller", :response => response)
    @filter.after(controller)
  end

  def test_escape_numeric_character_reference
    assert_equal "HTMLCSSINLINERESCAPE123456789::::::::", @filter.escape_numeric_character_reference("&#123456789;")
    assert_equal "HTMLCSSINLINERESCAPEx123def::::::::", @filter.escape_numeric_character_reference("&#x123def;")
  end

  def test_unescape_numeric_character_reference
    assert_equal "&#123456789;", @filter.unescape_numeric_character_reference("HTMLCSSINLINERESCAPE123456789::::::::")
    assert_equal "&#x123def;", @filter.unescape_numeric_character_reference("HTMLCSSINLINERESCAPEx123def::::::::")
  end

  def test_pseudo_selectors
    css = TinyCss.new.read_string(<<-CSS)
a:visited { color: FF00FF; }
    CSS
    assert_equal ["a:visited"], @filter.pseudo_selectors(css)

    css = TinyCss.new.read_string(<<-CSS)
.purple { color: FF00FF; }
    CSS
    assert_equal [], @filter.pseudo_selectors(css)
  end

  def test_stylesheet_link_node
    doc = Nokogiri::HTML(<<-HTML)
<link href="a.css"/>
<link href="b.css" rel="stylesheet"/>
    HTML

    @filter.stylesheet_link_node(doc).each do |node|
      assert_equal 'b.css', node['href']
    end
  end

  def test_extract_pseudo_style
    css = TinyCss.new.read_string <<-CSS
a:link    { color: red; }
a:focus   { color: green; }
a:visited { color: blue; }
div.title { background-color: #999 }
    CSS

    pseudo_style = @filter.extract_pseudo_style css
    assert_equal('red', pseudo_style.style['a:link']['color'])
    assert_equal('green', pseudo_style.style['a:focus']['color'])
    assert_equal('blue', pseudo_style.style['a:visited']['color'])
    assert_equal('#999', css.style['div.title']['background-color'])
  end

  def test_embed_pseudo_style
    css = TinyCss.new
    assert_equal nil, @filter.embed_pseudo_style(nil, css)

    css = TinyCss.new.read_string <<-CSS
a:link    { color: red; }
a:focus   { color: green; }
a:visited { color: blue; }
    CSS

    doc = Nokogiri::HTML <<-HTML
<html>
<head></head>
<body></body>
</html>
    HTML
    doc = @filter.embed_pseudo_style doc, css
    assert_match %r'<style .*?/style>'m, doc.to_xhtml

    doc = Nokogiri::HTML <<-HTML
<html>
<body></body>
</html>
    HTML
    assert_raise RuntimeError do
      @filter.embed_pseudo_style doc, css
    end
  end

  def test_embed_style
    css = TinyCss.new.read_string <<-CSS
.title { color: red; }
    CSS

    doc = Nokogiri::HTML <<-HTML
<html>
<body>
<div class="title">bar</div>
</body>
</html>
    HTML
    @filter.embed_style doc, css
    assert_match %r'style="color:red"', doc.to_xhtml

    doc = Nokogiri::HTML <<-HTML
<html>
<body>
<div class="title" style="background-color:black">bar</div>
</body>
</html>
    HTML
    @filter.embed_style doc, css
    assert_match %r'style="background-color:black;color:red"', doc.to_xhtml

    doc = Nokogiri::HTML <<-HTML
<html>
<body>
<div class="title" style="background-color:silver;">bar</div>
</body>
</html>
    HTML
    @filter.embed_style doc, css
    assert_match %r'style="background-color:silver;color:red"', doc.to_xhtml
  end

  def test_xml_declare
    doc = stub("doc", :encoding => "Shift_JIS")
    assert_equal <<-XML, @filter.xml_declare(doc)
<?xml version="1.0" encoding="Shift_JIS"?>
    XML

    doc = stub("doc", :encoding => "UTF-8")
    assert_equal <<-XML, @filter.xml_declare(doc)
<?xml version="1.0" encoding="UTF-8"?>
    XML
  end

  def test_remove_xml_declare
    assert_equal '', @filter.remove_xml_declare('<?xml version="1.0"?>')
    assert_equal '', @filter.remove_xml_declare('<?xml encoding="Shift_JIS"?>')
    assert_equal '', @filter.remove_xml_declare('<?xml version="1.0" encoding="Shift_JIS" ?>')
    assert_equal '', @filter.remove_xml_declare('<?xml?>')
  end

  def test_output_with_docomo_1_0_browser
    request = stub('request', :user_agent => 'DoCoMo/2.0 D905i(c100;TB;W24H17)')
    response = stub("response") do
      expects(:content_type).returns('application/xhtml+xml')
      expects(:body).returns(File.open(File.join(File.dirname(__FILE__), '../actual.html'), 'rb'){ |f| f.read })
      expects(:body=).with(File.open(File.join(File.dirname(__FILE__), '../expected.html'), 'rb'){ |f| f.read })
    end
    controller = stub("controller", :response => response, :request => request)

    @filter.after(controller)
  end

  def test_output_with_docomo_1_0_browser_and_utf8_charset
    request = stub('request', :user_agent => 'DoCoMo/2.0 D905i(c100;TB;W24H17)')
    response = stub("response") do
      expects(:content_type).returns('application/xhtml+xml; charset=utf-8')
      expects(:body).returns(File.open(File.join(File.dirname(__FILE__), '../actual.html'), 'rb'){ |f| f.read })
      expects(:body=).with(File.open(File.join(File.dirname(__FILE__), '../expected.html'), 'rb'){ |f| f.read })
    end
    controller = stub("controller", :response => response, :request => request)

    @filter.after(controller)
  end

  def test_output_with_docomo_2_0_browser
    request = stub('request', :user_agent => 'DoCoMo/2.0 N03B(c500;TB;W24H16)')
    response = stub("response") do
      expects(:content_type).returns('application/xhtml+xml')
      expects(:body).never
    end
    controller = stub("controller", :response => response, :request => request)

    @filter.after(controller)
  end
end
