class CreateContactMessage < ApplicationAction

  Result = ImmutableStruct.new(:contact_message_created?)

  def initialize(contact_message, request, policy: ContactMessageCreation)
    @contact_message = contact_message
    @request = request
    @policy = policy.new @contact_message.content
  end

  def call
    @contact_message.set_request @request

    if @policy.allowed? and @contact_message.save

      ContactMessageSpamcheckJob.perform_later(@contact_message)

      @contact_message.site.users.each do |user|
        UnreadItem.create user: user, item: @contact_message
      end

      Result.new contact_message_created: true

    else

      Result.new

    end
  end

end

