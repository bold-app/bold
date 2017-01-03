class IndexContent < ApplicationAction

  Result = ImmutableStruct.new(:index_updated?)

  def initialize(content = nil)
    @content = content
  end

  def call(content = @content)
    return false unless content&.fulltext_searchable?

    indices = content.fulltext_indices

    # public index
    if content.published?
      idx = find_index content, published: true
      idx.data = content.data_for_index
      idx.save!
    else
      indices.where(published: true).delete_all
    end

    # non published content
    idx = find_index content, published: false
    if content.has_draft?
      drafted_content = content.class.find(content.id)
      drafted_content.load_draft
      idx.data = drafted_content.data_for_index
      idx.save!
    elsif content.draft?
      idx.data = content.data_for_index
      idx.save!
    else
      indices.where(published: false).delete_all
    end

    Result.new index_updated: true
  end

  def self.rebuild_index(site = Bold.current_site)
    Bold.with_site(site) do
      indexer = new
      RebuildIndex.new(site, Content).call do |asset|
        indexer.call asset
      end
    end
  end

  private

  def find_index(content, published:)
    content.fulltext_indices.
      where(published: published).
      first_or_initialize(site_id: content.site_id)
  end

end
