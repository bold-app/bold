class ImportSite
  include Action

  def initialize(site, zipfile)
    @site = site
    @zipfile = zipfile
  end

  def call
    ::Bold::SiteExport.new(@site, @zipfile).import!
  end

end
