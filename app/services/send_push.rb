class SendPush
  def initialize(token, device)
    @client = PushbulletRuby::Client.new(token)
    @device = device
  end

  def send_test
    push_note('title', 'body')
  end

  def send_birthday_today

  end

  def send_birthdays_x_day(birthdays_x_day)
    content = birthdays_x_day.map { |x| "#{x[:name]} fêtera ses #{x[:number_days]} jours dans #{x[:x_days]} jours, le #{format_date(x[:date])}" }.join("\n")
    push_note('Annijour, rappel', content)
  end

  private

  def push_note(title, body)
    @client.push_note(
        receiver: :device,
        id: @device,
        params: {title: title, body: body}
    )
  end

  def format_date(date)
    I18n.l(date, format: '%e %B')
  end

end
# SendPush.new(ENV['PUSHBULLET_API_KEY'], ENV['NEXUS5X']).send_test
