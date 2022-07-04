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
      flash[:notice] = t('connections.new.success')
      connection_bot_notification(@connection, true)
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @connection.update(connection_params)
      flash[:notice] = t('connections.new.success')
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @connection.destroy
    connection_bot_notification(@connection, false)
    redirect_to user_path(@user)
  end

  private

  def connection_bot_notification(connection, status)
    action = status ? 'connected' : 'disconnected'
    I18n.with_locale(:bot) do
      Telegram.bot.send_message chat_id: connection.chat_id,
                                text:    t(action, key: connection.project_key)
    end
  end

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
