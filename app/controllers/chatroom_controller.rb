class ChatroomController < ApplicationController
  before_action :require_login

  def index
    @messages = Message.includes(:user).order(:created_at)
  end
end
