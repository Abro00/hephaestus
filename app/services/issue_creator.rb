class IssueCreator < ApplicationService
  def initialize(message)
    super
    @message = message
  end

  def call
    connection = Connection.find_by(chat_id: @message.dig('chat', 'id'))
    return I18n.t('no_connection') unless connection

    summary, description = parse_summary_and_description(@message['text'])

    client = jira_client(connection)

    issue, saved = save_issue(client, @message, summary, description, connection)
    if saved
      I18n.t('succ_issue', key: issue.key, site: client.request_client.options[:site])
    else
      I18n.t('fail_issue')
    end
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
    description = message.partition("\n\n")[2]
    summary = message.partition("\n\n")[0].partition(' ')[2]
    [summary, description]
  end

  def save_issue(client, message, summary, description, connection)
    issue = client.Issue.build
    project_key = connection.project_key
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
