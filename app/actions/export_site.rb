class ExportSite
  include Action

  def initialize(site, destination: Rails.root.join('exports'))
    @site = site
    @destination = destination
  end

  def call
    ::Bold::SiteExport.new(
      @site,
      File.join(@destination, "#{basename_for_export}.zip")
    ).export!
  end

  private

  def basename_for_export
    timestamp = @site.time_zone.now.strftime '%Y%m%d-%H%M'
    "#{@site.hostname.gsub(/\W/, '_')}_#{timestamp}"
  end

end
