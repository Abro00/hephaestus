class AddUserAndChatRefToConnections < ActiveRecord::Migration[7.0]
  def change
    add_reference :connections, :user, null: false, foreign_key: true
    add_reference :connections, :chat, null: false, foreign_key: true
  end
end
