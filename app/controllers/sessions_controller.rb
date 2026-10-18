class SessionsController < ApplicationController
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
end
