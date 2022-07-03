class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates :tg_token, :chat_id, :site, :email, :api_token, :project_key, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :jira_project_exists, :bot_connected

  def jira_project_exists
    options = {
      username:     email,
      password:     api_token,
      site:,
      context_path: '',
      auth_type:    :basic
    }
    client = JIRA::Client.new(options)

    begin
      client.Project.find(project_key)
    rescue JIRA::HTTPError
      errors.add(:base, message: I18n.t('models.connection.connection_error'))
    rescue StandardError
      errors.add(:base, message: I18n.t('models.connection.unknown_error'))
    end
  end

  def bot_connected
    Telegram.bot.get_me
  rescue Telegram::Bot::Error
    errors.add(:base, message: I18n.t('models.connection.bot_connection_error'))
  end
end
