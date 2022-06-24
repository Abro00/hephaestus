class TelegramWebhooksController < Telegram::Bot::UpdatesController
  def my_chat_member(my_chat_member)
    if my_chat_member['new_chat_member']['status'] == 'member'
      respond_with :message, text: 'Вечер в хату работяги'
      Chat.create(id: my_chat_member['chat']['id'], title: my_chat_member['chat']['title'])
    end
    Chat.find(my_chat_member['chat']['id']).destroy if my_chat_member['new_chat_member']['status'] == 'left'
  end

  def message(message)
    return if message['text'].nil?
    return unless message['text'].start_with?("@#{Telegram.bot.username}")

    summary, description = parse_summary_and_description(message['text'])

    options = {
      username:     Rails.application.credentials.dig(:jira, :username),
      password:     Rails.application.credentials.dig(:jira, :api_token),
      site:         Rails.application.credentials.dig(:jira, :site),
      context_path: '',
      auth_type:    :basic
    }
    client = JIRA::Client.new(options)

    issue, saved = save_issue(client, message, summary, description)
    if saved
      response = "Создана задача с номером [#{issue.key}](#{client.request_client.options[:site]}browse/#{issue.key})"
      reply_with :message, text: response, parse_mode: 'Markdown'
    else
      reply_with :message, text: 'Не удалось создать задачу'
    end
  end

  def start!(*)
    reply_with :message, text: 'Hello'
  end

  private

  def parse_summary_and_description(message)
    description = message.partition("\n\n")[2]
    summary = message.partition("\n\n")[0].partition(' ')[2]
    [summary, description]
  end

  def save_issue(client, message, summary, description)
    issue = client.Issue.build
    description << ("\n\nСоздано @#{message['from']['username']} в \"#{message['chat']['title']}\"" \
      ", [#{Time.at(message['date']).strftime('%R %d.%m.%y')}]")
    [issue, issue.save(
      {
        'fields' => {
          'summary'     => summary,
          'project'     => { 'key' => 'GEGE' },
          'description' => description,
          'issuetype'   => { 'name' => 'Task' }
        }
      }
    )]
  end
end
