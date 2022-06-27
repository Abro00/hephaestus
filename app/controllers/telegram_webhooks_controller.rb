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

    connection = Connection.find_by(chat_id: message['chat']['id'])
    unless connection
      respond_with :message, text: t('no_connection')
      return
    end

    summary, description = parse_summary_and_description(message['text'])

    client = set_jira_client(connection)

    issue, saved = save_issue(client, message, summary, description, connection)
    if saved
      response = t('succ_issue', key: issue.key, site: client.request_client.options[:site])
      reply_with :message, text: response, parse_mode: 'Markdown'
    else
      reply_with :message, text: t('fail_issue')
    end
  end

  def start!(*)
    reply_with :message, text: t('hello')
  end

  def help!(*)
    respond_with :message, text: t('help', botname: Telegram.bot.username), parse_mode: 'Markdown'
  end

  private

  def set_jira_client(connection)
    options = {
      username:     connection.email,
      password:     connection.api_token,
      site:         connection.site,
      context_path: '',
      auth_type:    :basic
    }
    JIRA::Client.new(options)
  end

  def parse_summary_and_description(message)
    description = message.partition("\n\n")[2]
    summary = message.partition("\n\n")[0].partition(' ')[2]
    [summary, description]
  end

  def save_issue(client, message, summary, description, connection)
    issue = client.Issue.build
    project_key = connection.project_key
    description << t('creation_info', creator: message['from']['username'],
                                      chat:    message['chat']['title'],
                                      time:    I18n.l(Time.at(message['date']), format: :custom))
    [issue, issue.save(
      {
        fields: {
          summary:,
          project:     { key: project_key },
          description:,
          issuetype:   { name: 'Task' }
        }
      }
    )]
  end
end
