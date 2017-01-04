class CreatePermalink < ApplicationAction

  Result = ImmutableStruct.new(:link_created?, :link)

  def initialize(destination, *path)
    raise 'destination of link has to be persisted already' unless destination.persisted?
    @destination = destination
    @path = Array(path).flatten
  end

  # links @path to destination
  #
  # this handles both the case where an existing permalink needs to be
  # redirected to the new path, and where this is the first link to be created
  # for destination.
  def call
    path = Permalink.build_path(*@path)

    @destination.transaction do

      # any redirect redirecting from the location we want to create a link for
      # will be removed.
      if existing_redirect_link = existing_redirect_link_for(path)
        existing_redirect_link.destination.destroy
      end

      # if object already has a permalink, this will be redirected to the new
      # location
      if link = @destination.permalink

        link.redirect_to(*@path)
        if link.changed?
          link.save!

          link = if existing_redirect_link
            existing_redirect_link
          else
            Permalink.new path: path
          end

          link.destination = @destination
          if link.save
            @destination.reload
            return Result.new link_created: true, link: link
          end

        else
          return Result.new link_created: true, link: link
        end


      else
        # reuse existing previously redirecting link record or create a new one

        link = existing_redirect_link || Permalink.new(path: path)
        link.destination = @destination

        if link.save
          @destination.permalink = link
          return Result.new link_created: true, link: link
        end

      end

      # no success, cancel the transaction
      raise ActiveRecord::Rollback
    end

    return Result.new link_created: false
  end


  private

  def existing_redirect_link_for(path)
    if existing_link = Permalink.find_by_path(path) and
      existing_link.destination.is_a?(Redirect)

      return existing_link
    end
  end

end
