xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
           "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
           "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" do

  call_hook :view_sitemaps_start, builder: xml

  if @homepage
    xml.url do
      xml.loc @homepage.canonical_url
      xml.changefreq 'always'
      xml.lastmod site.last_mod_date.iso8601
      xml.priority '1.0'
    end
  end

  @posts.each do |post|
    xml.url do
      xml.loc post.canonical_url
      xml.changefreq 'daily'
      xml.lastmod post.meta_mod_date || post.meta_pub_date
      xml.priority '0.8'
    end
  end

  @pages.each do |page|
    xml.url do
      xml.loc page.canonical_url
      xml.changefreq 'daily'
      xml.lastmod page.meta_mod_date || page.meta_pub_date
      xml.priority '0.7'
    end
  end

  @categories.each do |cat|
    xml.url do
      xml.loc cat.canonical_url
      xml.changefreq 'daily'
      if post = cat.last_post
        xml.lastmod post.meta_mod_date || post.meta_pub_date
      end
      xml.priority '0.6'
    end
  end if @categories

  @authors.each do |author|
    xml.url do
      xml.loc author.canonical_url
      xml.changefreq 'daily'
      if post = author.last_post
        xml.lastmod post.meta_mod_date || post.meta_pub_date
      end
      xml.priority '0.6'
    end
    xml.priority '0.6'
  end if @authors

  @tags.each do |tag|
    xml.url do
      xml.loc tag.canonical_url
      xml.changefreq 'daily'
      if post = tag.last_post
        xml.lastmod post.meta_mod_date || post.meta_pub_date
      end
      xml.priority '0.5'
    end
  end if @tags

  call_hook :view_sitemaps_end, builder: xml

end

