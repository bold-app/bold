class RebuildIndex

  def initialize(site, model)
    @site = site
    @model_class = model
    @model_class_name = model.name
  end

  def call
    FulltextIndex.transaction do

      FulltextIndex.
        where(site_id: @site.id,
              searchable_type: @model_class_name).
        delete_all

      @model_class.
        where(site_id: @site.id).
        find_in_batches(batch_size: 100) do |group|
        group.each{ |o| yield o }
      end

    end
  end

end
