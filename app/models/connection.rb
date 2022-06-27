class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates :tg_token, :chat_id, :site, :email, :api_token, :project_key, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
