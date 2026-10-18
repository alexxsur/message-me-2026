class ChatroomController < ApplicationController
  before_action :require_login

  def index
    @messages = Message.all
  end
end
