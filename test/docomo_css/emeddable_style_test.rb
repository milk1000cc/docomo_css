require 'test_helper'
require File.join File.dirname(__FILE__), '..', '..', 'lib', 'docomo_css', 'embeddable_style'

class DocomoCss::EmbeddableStyleTest < MiniTest::Test

  def test_embed_style_in_div
    doc = Nokogiri::HTML("<div>")
    div = doc.at("div")
    div.embed_style(style)
    assert_equal '<div style="color:red"></div>', doc.at("body").children.to_html
  end

  def test_embed_style_in_h1_handles_empty_children
    doc = Nokogiri::HTML("<h1>")
    e = doc.at("h1")
    e.embed_style(style)
    assert_equal '<h1></h1>', doc.at("body").children.to_html
  end

  def test_embed_style_in_h1_handles_wrapping_of_color
    doc = Nokogiri::HTML("<h1>foo</h1>")
    e = doc.at("h1")
    e.embed_style(style)
    assert_equal '<h1><span style="color:red">foo</span></h1>', doc.at("body").children.to_html
  end

  def test_embed_style_obeys_inject_unsupported_styles
    doc = Nokogiri::HTML("<h1>foo</h1>")
    e = doc.at("h1")
    e.embed_style(style, :inject_unsupported_styles => false)
    assert_equal '<h1 style="color:red">foo</h1>', doc.at("body").children.to_html
  end

  def test_embed_style_in_h1_handles_wrapping_of_font_size
    doc = Nokogiri::HTML("<h1>foo</h1>")
    e = doc.at("h1")
    e.embed_style(style('font-size', 'x-small'))
    assert_equal '<h1><span style="font-size:x-small">foo</span></h1>', doc.at("body").children.to_html
  end

  def test_embed_style_in_h1_handles_wrapping_of_background_color
    doc = Nokogiri::HTML("<h1>foo</h1>")
    e = doc.at("h1")
    e.embed_style(style('background-color', 'red'))
    assert_equal '<div style="background-color:red"><h1>foo</h1></div>', doc.at("body").children.to_html
  end

  def test_embed_style_in_div_handles_existing_style_attribute
    doc = Nokogiri::HTML("<div style='font-size:x-small'>foo</div>")
    e = doc.at("div")
    e.embed_style(style)
    assert_equal '<div style="font-size:x-small;color:red">foo</div>', doc.at("body").children.to_html
  end

  def test_embed_style_in_h1_handles_style_in_h1
    doc = Nokogiri::HTML("<h1 style='margin-top: 10px;'>foo</h1>")
    e = doc.at("h1")
    e.embed_style(style)
    assert_equal %q{<h1 style="margin-top: 10px;"><span style="color:red">foo</span></h1>}, doc.at("body").children.to_html
  end

  def test_merge_style
    e = Nokogiri.make("<h1>")
    e.merge_style('color:red')
    assert_equal '<h1 style="color:red"></h1>', e.to_html
    e = Nokogiri.make('<h1 style="color:red">')
    e.merge_style('font-size:small')
    assert_equal '<h1 style="color:red;font-size:small"></h1>', e.to_html
    e = Nokogiri.make('<h1 style="color:red;">')
    e.merge_style('font-size:small')
    assert_equal '<h1 style="color:red;font-size:small"></h1>', e.to_html
  end

  def test_embed_style_in_h1_handles_multiple_styles
    doc = Nokogiri::HTML("<h1>foo</h1>")
    e = doc.at("h1")
    style = TinyCss::OrderedHash.new
    style["font-size"] = "medium"
    style["color"] = "#ffffff"
    style["text-align"] = "center"
    style["background"] = "#215f8b"
    style["margin-top"] = "5px"
    e.embed_style(style)
    assert_equal %q{<div style="background:#215f8b"><h1 style="text-align:center;margin-top:5px"><span style="font-size:medium;color:#ffffff">foo</span></h1></div>}, doc.at("body").children.to_html
  end

  def test_embed_style_in_p_handles_color
    doc = Nokogiri::HTML("<p>foo</p>")
    e = doc.at("p")
    e.embed_style(style)
    assert_equal '<p><span style="color:red">foo</span></p>', doc.at("body").children.to_html
  end

  def test_embed_style_in_p_handles_background_color
    doc = Nokogiri::HTML("<p>foo</p>")
    e = doc.at("p")
    e.embed_style(style('background-color', 'red'))
    assert_equal '<div style="background-color:red"><p>foo</p></div>', doc.at("body").children.to_html
  end

  private

  def style(attribute = 'color', value = 'red')
    style = TinyCss::OrderedHash.new
    style[attribute] = value
    style
  end
end
