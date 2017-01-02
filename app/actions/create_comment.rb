class CreateComment < ApplicationAction

  Result = ImmutableStruct.new(:comment_created?, :message)

  def initialize(comment, request, policy: CommentCreation)
    @comment = comment
    @request = request
    @policy = policy.new @comment.content
  end

  def call
    unless @policy.allowed?
      return Result.new message: t('.disabled')
    end

    @comment.set_request @request
    if @comment.save
      message = if @comment.site.auto_approve_comments?
                  t('.appears_soon')
                else
                  t('.awaits_moderation')
                end

      @comment.site.users.each do |user|
        UnreadItem.create user: user, item: @comment
      end

      CommentApprovalJob.perform_later(@comment)

      Result.new comment_created: true, message: message
    else
      Result.new message: t('.not_saved')
    end
  end

end
