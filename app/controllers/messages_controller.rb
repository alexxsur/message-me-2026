class MessagesController < ApplicationController
  before_action :require_login

  def create
    message = current_user.messages.build(message_params)

    if message.save
      head :no_content
    else
      redirect_to root_path, alert: message.errors.full_messages.to_sentence
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end
