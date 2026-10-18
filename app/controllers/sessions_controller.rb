class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(username: params[:username])

    if params[:password].present? && user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "You have signed in."
    else
      flash.now[:alert] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You have logged out."
  end

  private

  def redirect_if_logged_in
    redirect_to root_path, alert: "You are already logged in." if logged_in?
  end
end
