# Saves changes to an already published content object as a draft.
#
# Content that's not published yet is just saved.
#
class SaveDraft
  include Action

  Result = ImmutableStruct.new(:draft_saved?, :message)

  def initialize(content)
    @content = content
  end

  def call
    @content.transaction do

      if @content.published?
        # FIXME check on what happens during validations that we need to be done
        # and do it here
        @content.valid?
        @content.errors.clear

        draft.take_changes

        if @content.new_record?
          @content.save validate: false
        end

        if draft.save
          # bump up updated_at (and make sure after_save hooks get triggered even
          # if we only saved the draft in case of an already published content)
          # FIXME check hooks for stuff to move here
          @content.touch
          return Result.new draft_saved: true
        end

      elsif @content.save

        ApplyTags.call @content if @content.is_a? Post

        return Result.new draft_saved: true
      end

      raise ActiveRecord::Rollback
    end

    return Result.new draft_saved: false, message: @content.errors.full_messages
  end


  private

  def draft
    @draft ||= @content.draft || Draft.new(content: @content)
  end
end
