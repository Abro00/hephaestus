class ConnectionsController < ApplicationController
  before_action :find_user
  before_action :set_connection, only: %i[edit update destroy]
  before_action :set_chats_collection, only: %i[new create edit]

  def new
    @connection = @user.connections.new
  end

  def create
    @connection = @user.connections.new(connection_params)

    if @connection.save
      redirect_to user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    # проверка соединения

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

  def check_connection(connection)
    options = {
      username:     connection.email,
      password:     connection.api_token,
      site:         connection.site,
      context_path: '',
      auth_type:    :basic
    }
    client = JIRA::Client.new(options)

    begin client.Project.find(connection.project_key)
          true
    rescue StandardError
      false
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
  end

  def connection_params
    params.require(:connection).permit(:chat_id, :tg_token, :site, :email, :api_token, :project_key)
  end
end
