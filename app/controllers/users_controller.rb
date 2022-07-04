class UsersController < ApplicationController
  def index
    redirect_to new_user_session_path
  end

  def show
    @user = User.find(params[:id])
    redirect_to user_path(current_user) unless @user == current_user
  end
end
