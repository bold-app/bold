class ExportSite
  include Action

  Result = ImmutableStruct.new(:success?, :zipfile, [:errors])

  def initialize(site, destination: Rails.root.join('exports'))
    @site = site
    @destination = destination
  end

  def call
    e = ::Bold::SiteExport.new(
      @site,
      File.join(@destination, "#{basename_for_export}.zip")
    )
    path = e.export!
    if File.readable?(path) and File.size(path) > 0
      Result.new(success: true, zipfile: path, errors: e.errors)
    else
      Result.new(success: false, errors: e.errors)
    end
  end

  private

  def basename_for_export
    timestamp = @site.time_zone.now.strftime '%Y%m%d-%H%M'
    "#{@site.hostname.gsub(/\W/, '_')}_#{timestamp}"
  end

end
