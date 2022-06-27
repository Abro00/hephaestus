class TelegramWebhooksController < Telegram::Bot::UpdatesController
  I18n.locale = 'bot'

  # adding bot to a new group
  def my_chat_member(my_chat_member)
    if my_chat_member['new_chat_member']['status'] == 'member'
      respond_with :message, text: t('chat_ivite')

      Chat.create(id: my_chat_member['chat']['id'], title: my_chat_member['chat']['title'])
    end
    Chat.find(my_chat_member['chat']['id']).destroy if my_chat_member['new_chat_member']['status'] == 'left'
  end

  # request to create issue
  def message(message)
    return if message['text'].nil?
    return unless message['text'].start_with?("@#{Telegram.bot.username}")

    if message['chat']['type'] == 'private'
      respond_with :message, text: t('private_mention')
      return
    end

    response =  IssueCreator.call(message)
    reply_with :message, text: response, parse_mode: 'Markdown'
  end

  def start!(*)
    reply_with :message, text: t('hello')
  end

  def help!(*)
    respond_with :message, text: t('help', botname: Telegram.bot.username), parse_mode: 'Markdown'
  end
end
