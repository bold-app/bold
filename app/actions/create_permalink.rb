class CreatePermalink
  include Action

  Result = ImmutableStruct.new(:link_created?, :link)

  def initialize(destination, *path)
    @destination = destination
    @path = Array(path).flatten
  end

  # links @path to destination
  #
  # this handles both the case where an existing permalink needs to be
  # redirected to the new path, and where this is the first link to be created
  # for destination.
  def call
    @destination.transaction do

      if @destination.permalink

        if update(@destination, @path)
          return Result.new link_created: true, link: @destination.permalink
        end

      elsif pl = link_for(@path)

        pl.destination = @destination
        @destination.permalink = pl
        if @destination.save and pl.save
          return Result.new link_created: true, link: pl
        end

      end

      # no success, cancel the transaction
      raise ActiveRecord::Rollback
    end

    return Result.new link_created: false
  end


  private

  # initializes a permalink that maps the given path
  #
  # in case a redirect to this path exists, it will be removed and the existing
  # link record returned
  def link_for(*path)
    path = Permalink.build_path(*path)

    if existing_link = Permalink.find_by_path(path)
      if existing_link.destination.is_a?(Redirect)

        # prevent collision with existing redirect by removing it
        existing_link.destination.destroy
        # and reuse the link record
        return existing_link
      end
    else
      return Permalink.new path: path
    end
    nil
  end


  # changes object's permalink to map path to object. the old link will stay
  # and redirect to the new path.
  def update(object, *path)
    if old_link = object.permalink
      old_link.redirect_to(*path)
      if old_link.changed?
        old_link.save!
        new_link = link_for(*path)
        new_link.destination = object
        new_link.save!
        return new_link
      end
    end
  end

end
