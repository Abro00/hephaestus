class TelegramWebhooksController < Telegram::Bot::UpdatesController
  
  def new!(*)
    header, body = parse_header_and_body(payload['text'])
    response = "Created new Jira task with\n\nheader: #{header}\n\nbody: #{body}"
    reply_with :message, text: response
  end

  def start!(*)
    reply_with :message, text: 'Hello'
  end

  private

  def parse_header_and_body(message)
    body = message.partition("\n\n")[2]
    header = message.partition("\n\n")[0].partition(" ")[2]
    [header, body]
  end

end