class ConnectionsController < ApplicationController
  before_action :find_user

  def new
    @connection = @user.connections.new
    @chats_collection = Chat.left_joins(:connection).where(connection: { chat_id: nil })
  end

  def create
    @connection = @user.connections.new(connection_params)
    @chats_collection = Chat.left_joins(:connection).where(connection: { chat_id: nil })

    if @connection.save
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @connection = Connection.find(params[:id])
    @chats_collection = Chat.left_joins(:connection).where(connection: { chat_id: nil })
                            .or(Chat.where(connection: { chat_id: @connection.chat_id }))
  end

  def update
    @connection = Connection.find(params[:id])

    if @connection.update(connection_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    connection = @user.connections.find(params[:id])
    connection.destroy
    redirect_to user_path(@user)
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def connection_params
    params.require(:connection).permit(:chat_id, :tg_token, :site, :email, :api_token, :project_key)
  end
end
