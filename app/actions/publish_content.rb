class PublishContent < ApplicationAction

  Result = ImmutableStruct.new(:published?, :error)

  def initialize(content)
    @content = content
  end

  # Publishes a post or page.
  #
  # A possibly existing draft will be deleted.
  def call
    save_state

    if @content.publish
      Content.transaction do

        @content.delete_draft

        if @content.scheduled?
          # publish later
          @content.save!
          PublisherJob.set(wait_until: @content.post_date).perform_later(@content)

        else
          # publish now
          @content.save!
          CreatePermalink.call @content, @content.permalink_path_args

          if @was_not_published
            RpcPingJob.perform_later @content
          end

        end


      end
      Result.new published: true

    else
      # nothing to do
      Result.new published: false
    end

  rescue ActiveRecord::RecordInvalid
    Rails.logger.warn "record invalid in publish action: #{$!}"
    restore_state
    Result.new published: false, error: $!
  end

  private

  def save_state
    @old_attributes = @content.attributes.slice 'status', 'post_date', 'last_update'
    @was_not_published = !@content.published?
  end

  def restore_state
    @content.attributes = @old_attributes if @old_attributes
  end
end
