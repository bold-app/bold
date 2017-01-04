# Saves changes to an already published content object as a draft.
#
# Content that's not published yet is just saved.
#
class SaveDraft < ApplicationAction

  Result = ImmutableStruct.new(:draft_saved?, :message)

  def initialize(content)
    @content = content
  end

  def call
    @content.transaction do

      if @content.published?

        draft.take_changes

        if @content.new_record?
          @content.save validate: false
        end

        if draft.save
          # bump up updated_at
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
