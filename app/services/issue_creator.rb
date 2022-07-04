class IssueCreator < ApplicationService
  class IssueError < StandardError; end

  def initialize(message)
    @message = message
  end

  def call
    connection = Connection.find_by(chat_id: @message.dig('chat', 'id'))
    raise IssueError.new(I18n.t('no_connection')) unless connection

    client = jira_client(connection)
    issue, saved = save_issue(client, @message, connection)
    raise IssueError.new(I18n.t('fail_issue')) unless saved

    {
      success: true,
      message: I18n.t('succ_issue', key: issue.key, site: connection.site)
    }
  rescue IssueError => e
    { success: false, message: e.message }
  end

  private

  def jira_client(connection)
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
    summary, _separator, description = message.partition("\n\n")
    summary = summary.gsub("@#{Telegram.bot.username}", '').squish
    [summary, description]
  end

  def save_issue(client, message, connection)
    issue = client.Issue.build
    project_key = connection.project_key

    summary, description = parse_summary_and_description(message['text'])
    description << I18n.t('creation_info', creator: message.dig('from', 'username'),
                                           chat:    message.dig('chat', 'title'),
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
