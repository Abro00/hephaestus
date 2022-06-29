class UsersController < ApplicationController
  def index; end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
