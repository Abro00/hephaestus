class ConnectionsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @connection = @user.connections.new
  end

  def create
    @user = User.find(params[:user_id])
    @connection = @user.connections.new(connection_params)

    if @connection.save
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def connection_params
    params.require(:connection).permit(:chat_id, :tg_token, :site, :email, :api_token, :project_key)
  end
end
