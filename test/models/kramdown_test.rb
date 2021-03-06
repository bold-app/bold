#
# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

class KramdownTest < ActiveSupport::TestCase
  include Markdown

  setup do
    RequestStore.store[:preview_mode] = nil
  end

  test 'should sanitize output' do
    markdown = %{'';!--"<XSS>=&{()}}
    assert_equal %{<p>'';!--"&lt;XSS&gt;=&amp;{()}</p>\n}, md_render_text(markdown)
    assert_equal %{<p>’’;!–“=&amp;{()}</p>\n}, md_render_text(markdown, true)
  end

  test 'should render code block as figure' do
    markdown = <<-MARKDOWN.strip_heredoc

      ~~~ruby
      def foo
        42
      end
      ~~~~
      {:title="Lorem ipsum"}

    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)

<figure class="code highlighter-coderay"><figcaption>Lorem ipsum</figcaption><pre class=\"highlight\"><code><span class=\"keyword\">def</span> <span class=\"function\">foo</span>
  <span class=\"integer\">42</span>
<span class=\"keyword\">end</span>
</code></pre></figure>

    HTML
  end

  test 'should render figure' do
    markdown = <<-MARKDOWN.strip_heredoc

      ![](foo.jpg "this is the caption")

    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)

      <figure class="image"><img src="foo.jpg" alt="" title="this is the caption"><figcaption>this is the caption</figcaption></figure>

    HTML
  end

  test 'should recognize figure ial before' do
    markdown = <<-MARKDOWN.strip_heredoc
      {:.left}
      ![](foo.jpg "caption")
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="image left"><img src="foo.jpg" alt="" title="caption"><figcaption>caption</figcaption></figure>
    HTML

    markdown = <<-MARKDOWN.strip_heredoc
      {:style="width: 100px;"}
      ![](foo.jpg "caption")
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure style="width: 100px;" class="image"><img src="foo.jpg" alt="" title="caption"><figcaption>caption</figcaption></figure>
    HTML
  end

  test 'should recognize image ial' do
    markdown = <<-MARKDOWN.strip_heredoc
      ![](foo.jpg "caption"){:style="width: 100px;"}
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="image"><img src="foo.jpg" alt="" title="caption" style="width: 100px;"><figcaption>caption</figcaption></figure>
    HTML
  end

  test 'should recognize figure ial after' do
    markdown = <<-MARKDOWN.strip_heredoc
      ![](foo.jpg "caption")
      {:.left}
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="image left"><img src="foo.jpg" alt="" title="caption"><figcaption>caption</figcaption></figure>
    HTML
  end

  test 'should recognize inline image ial after' do
    markdown = <<-MARKDOWN.strip_heredoc
      ![](foo.jpg "caption"){:.left}
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="image left"><img src="foo.jpg" alt="" title="caption" class="left"><figcaption>caption</figcaption></figure>
    HTML
  end

  test 'should render definition list' do
    markdown = <<-MARKDOWN.strip_heredoc
      foo

      term
      : this is the
        definition

      another term
      : short definition

      bar
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <p>foo</p>

      <dl>
        <dt>term</dt>
        <dd>this is the
      definition</dd>
        <dt>another term</dt>
        <dd>short definition</dd>
      </dl>

      <p>bar</p>
    HTML
  end

  test 'should render markdown' do
    markdown = <<-MARKDOWN.strip_heredoc
      # headline

      Paragraph

      - list
      - items
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <h1 id="headline">headline</h1>

      <p>Paragraph</p>

      <ul>
        <li>list</li>
        <li>items</li>
      </ul>
    HTML
  end

  test 'should strip not allowed attributes' do
    assert_equal %{<p><img src="/"></p>\n}, md_render_text(%{<img src="/" onerror="alert('XSS')" />}, true)
  end

  test 'should strip evil attributes' do
    [
      [ %{<img src="javascript:alert('XSS')" />}, '<img>' ],
      [ %{<IMG SRC=`javascript:alert("RSnake says, 'XSS'")`>},
          %{&lt;IMG SRC=<code>javascript:alert(\"RSnake says, 'XSS'\")</code>&gt;} ],
      [ %{<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>}, %{&lt;IMG SRC=javascript:alert(String.fromCharCode(88,83,83))&gt;}],
      [ %{<img src=javascript:alert(String.fromCharCode(88,83,83))>}, %{&lt;img src=javascript:alert(String.fromCharCode(88,83,83))&gt;}],
      [ %{&lt;img src=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>}, %{&lt;img src=&amp;#0000106&amp;#0000097&amp;#0000118&amp;#0000097&amp;#0000115&amp;#0000099&amp;#0000114&amp;#0000105&amp;#0000112&amp;#0000116&amp;#0000058&amp;#0000097&amp;#0000108&amp;#0000101&amp;#0000114&amp;#0000116&amp;#0000040&amp;#0000039&amp;#0000088&amp;#0000083&amp;#0000083&amp;#0000039&amp;#0000041&gt;} ],
      [ %{<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>}, %{&lt;IMG SRC=javascript:alert('XSS')&gt;}],
      [ %{<img src="jav&#x09;ascript:alert('XSS');">}, %{<img>}],
      [ %{<img src=java script:alert("XSS")>}, %{&lt;img src=java script:alert(“XSS”)&gt;}],
    ].each do |x, e|
      assert_equal %{<p>#{e}</p>\n}, md_render_text(x, true)
    end
  end

  test 'should escape unknown tags' do
    # on untrusted input, we html escape *before* the markdown rendering, thats why the unknown tag stays there but is escaped.
    assert_equal '<p><em>foo</em> &lt;bar&gt; &amp;</p>', md_render_text('*foo* <bar> &amp;').strip
    # trusted input is markdown rendered and sanitized afterwards, which strips the still unescaped <bar> tag.
    assert_equal '<p><em>foo</em>  &amp;</p>', md_render_text('*foo* <bar> &amp;', true).strip
  end


  test 'should increase headline levels if untrusted' do
    assert_equal '<h4>foo</h4>', md_render_text('# foo').strip
  end


  test 'should render markdown inside html block elements if trusted' do
    markdown = <<-MARKDOWN.strip_heredoc
      <aside class="foo" markdown="1">
        Lorem *ipsum*
      </aside>
    MARKDOWN

    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <aside class="foo">
        <p>Lorem <em>ipsum</em></p>
      </aside>
    HTML

    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown)
      <p>&lt;aside class="foo" markdown="1"&gt;
        Lorem <em>ipsum</em>
      &lt;/aside&gt;</p>
    HTML

  end


  test 'should add nofollow to untrusted links' do
    assert_equal '<p><a href="/">foo</a></p>', md_render_text('[foo](/)', true).strip
    assert_equal '<p><a href="/" rel="nofollow">foo</a></p>', md_render_text('[foo](/)').strip
  end

  test 'should expand image reference with an escaped title' do
    Bold::current_site = site = create :site
    asset = create :asset, site: site
    page = create :page, site: site
    md = "![](#{asset.slug} 'title\'s text')\n"
    assert_equal <<-HTML.strip_heredoc, md_render_content(page, md)
      <figure class="image"><img src="#{asset.public_path}" alt="" title="title's text"><figcaption>title's text</figcaption></figure>
    HTML
  end

  test 'should expand image references in preview mode' do
    Bold::current_site = site = create :site
    asset = create :asset, site: site
    page = create :page, site: site

    Bold::Kramdown.preview_mode!

    md = "![alt text](#{asset.slug}!small)"
    assert_equal %{<figure class="image small"><img src="/bold/assets/#{asset.id}?version=bold_preview" alt="alt text" class="small"></figure>}, md_render_content(page, md).strip
  end

  test 'should expand image references' do
    Bold::current_site = site = create :site
    asset = create :asset, site: site
    page = create :page, site: site

    # no link, no version, no nothing
    md = "![](#{asset.slug})"
    assert_equal %{<figure class="image"><img src="#{asset.public_path}" alt=""></figure>}, md_render_content(page, md).strip

    # no link, no version
    md = "![alt text](#{asset.slug} 'title text')"
    assert_equal %{<figure class="image"><img src="#{asset.public_path}" alt="alt text" title="title text"><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with class
    md = "![alt text](#{asset.slug} 'title text'){:class=\"some-class\"}"
    assert_equal %{<figure class="image some-class"><img src="#{asset.public_path}" alt="alt text" title="title text" class="some-class"><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with short class
    md = "![alt text](#{asset.slug} 'title text'){:.some-class}"
    assert_equal %{<figure class="image some-class"><img src="#{asset.public_path}" alt="alt text" title="title text" class="some-class"><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with version
    md = "![alt text](#{asset.slug}!small)"
    assert_equal %{<figure class="image small"><img src="#{asset.public_path :small}" alt="alt text" class="small"></figure>}, md_render_content(page, md).strip

    # with link to other version
    md = "![](#{asset.slug}!small!big 'title text')"
    assert_equal %{<figure class="image small"><a href="#{asset.public_path :big}"><img src="#{asset.public_path :small}" alt="" title="title text" class="small"></a><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with link to other page
    md = "![](#{asset.slug}!small!/foo/bar 'title text')"
    assert_equal %{<figure class="image small"><a href="/foo/bar"><img src="#{asset.public_path :small}" alt="" title="title text" class="small"></a><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip
  end

end
