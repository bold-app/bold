# wraps all that might have to be done when saving a page or post.
#
# Uses the PublishContent, ApplyTags, SaveDraft and IndexContent actions.
class SaveContent
  include Action

  Result = ImmutableStruct.new(:saved?, :published?,
                               :message, :message_severity)


  def initialize(content, publish: false)
    @content = content
    @publish = publish

    @was_published = content.published?
    @had_changes   = content.changed?
  end

  def call

    published = false

    if publish?
      r = PublishContent.call @content
      if e = r.error
        return Result.new(saved: false, message: error_message(e),
                          message_severity: :alert)
      end
      published = r.published?

      ApplyTags.call @content if @content.is_a? Post

    else
      r = SaveDraft.call @content
      unless r.draft_saved?
        return Result.new(saved: false, message: error_message(r.message),
                          message_severity: :alert)
      end

    end


    IndexContent.call @content

    if (published && !@was_published) || @had_changes
      severity = :notice
      message = I18n.t flash_key('saved')

    else
      severity = :info
      message = I18n.t flash_key('no_changes')

    end

    Result.new saved: true,
               message: message,
               message_severity: severity,
               published: published
  end


  private

  def publish?
    !!@publish
  end

  def error_message(e)
    I18n.t flash_key('not_saved'), reason: e
  end

  def flash_key(base)
    "actions.save_content.#{base}#{'_draft' unless publish?}"
  end


end
