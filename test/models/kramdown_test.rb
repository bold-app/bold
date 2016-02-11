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

<figure class="code highlighter-coderay"><pre class=\"highlight\"><code><span class=\"keyword\">def</span> <span class=\"function\">foo</span>
  <span class=\"integer\">42</span>
<span class=\"keyword\">end</span>
</code></pre><figcaption>Lorem ipsum</figcaption></figure>

    HTML
  end

  test 'should render figure' do
    markdown = <<-MARKDOWN.strip_heredoc
      ![](foo.jpg)
      : this is the
        caption

    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="image">
        <img src="foo.jpg" alt="" />
        <figcaption>
          <p>this is the
      caption</p>
        </figcaption>
      </figure>

    HTML
  end

  test 'should respect figure ial after' do
    markdown = <<-MARKDOWN.strip_heredoc
      ![](foo.jpg)
      :   caption
      {:.left}
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="left image">
        <img src="foo.jpg" alt="" />
        <figcaption>
          <p>caption</p>
        </figcaption>
      </figure>
    HTML
  end

  test 'should respect figure ial before' do
    markdown = <<-MARKDOWN.strip_heredoc
      {:.left}
      ![](foo.jpg)
      : caption
    MARKDOWN
    assert_equal <<-HTML.strip_heredoc, md_render_text(markdown, true)
      <figure class="left image">
        <img src="foo.jpg" alt="" />
        <figcaption>
          <p>caption</p>
        </figcaption>
      </figure>
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


  test 'should escape html if untrusted' do
    assert_equal '<p><em>foo</em> <bar> &amp;</bar></p>', md_render_text('*foo* <bar> &amp;', true).strip
    assert_equal '<p><em>foo</em> &lt;bar&gt; &amp;</p>', md_render_text('*foo* <bar> &amp;').strip
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
    site = create :site
    asset = create :asset, site: site
    page = create :page, site: site
    md = "![](#{asset.slug} 'title\'s text')"
    assert_equal <<-HTML.strip_heredoc, md_render_content(page, md)
      <figure class="image"><img src="#{asset.public_path}" alt="" title="title's text" /><figcaption>title's text</figcaption></figure>
    HTML
  end

  test 'should expand image references in preview mode' do
    site = create :site
    asset = create :asset, site: site
    page = create :page, site: site

    Bold::Kramdown.preview_mode!

    md = "![alt text](#{asset.slug}!small)"
    assert_equal %{<figure class="image"><img src="/bold/assets/#{asset.id}?version=bold_preview" alt="alt text" class="small" /></figure>}, md_render_content(page, md).strip
  end

  test 'should expand image references' do
    site = create :site
    asset = create :asset, site: site
    page = create :page, site: site

    # no link, no version, no nothing
    md = "![](#{asset.slug})"
    assert_equal %{<figure class="image"><img src="#{asset.public_path}" alt="" /></figure>}, md_render_content(page, md).strip

    # no link, no version
    md = "![alt text](#{asset.slug} 'title text')"
    assert_equal %{<figure class="image"><img src="#{asset.public_path}" alt="alt text" title="title text" /><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with class
    md = "![alt text](#{asset.slug} 'title text'){:class=\"some-class\"}"
    assert_equal %{<figure class="image"><img src="#{asset.public_path}" alt="alt text" title="title text" class="some-class" /><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with version
    md = "![alt text](#{asset.slug}!small)"
    assert_equal %{<figure class="image"><img src="#{asset.public_path :small}" alt="alt text" class="small" /></figure>}, md_render_content(page, md).strip

    # with link to other version
    md = "![](#{asset.slug}!small!big 'title text')"
    assert_equal %{<figure class="image"><a href="#{asset.public_path :big}"><img src="#{asset.public_path :small}" alt="" title="title text" class="small" /></a><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip

    # with link to other page
    md = "![](#{asset.slug}!small!/foo/bar 'title text')"
    assert_equal %{<figure class="image"><a href="/foo/bar"><img src="#{asset.public_path :small}" alt="" title="title text" class="small" /></a><figcaption>title text</figcaption></figure>}, md_render_content(page, md).strip
  end

end