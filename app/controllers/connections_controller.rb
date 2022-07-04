class ConnectionsController < ApplicationController
  before_action :find_user
  before_action :set_connection, only: %i[edit update destroy]
  before_action :set_chats_collection, only: %i[new create edit update]

  def new
    @connection = @user.connections.new
  end

  def create
    @connection = @user.connections.new(connection_params)
    @connection.tg_token = Telegram.bot.token

    if @connection.save
      flash[:notice] = 'Connection successfully saved'
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @connection.update(connection_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @connection.destroy
    redirect_to user_path(@user)
  end

  private

  def set_chats_collection
    @chats_collection = Chat.left_joins(:connection).where(connection: { chat_id: [nil, @connection&.chat_id].uniq })
  end

  def set_connection
    @connection = Connection.find(params[:id])
  end

  def find_user
    @user = User.find(params[:user_id])
    redirect_to user_path(current_user) unless @user == current_user
  end

  def connection_params
    params.require(:connection).permit(:chat_id, :site, :email, :api_token, :project_key)
  end
end
