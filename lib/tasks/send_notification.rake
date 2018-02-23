task :send_notification => :environment do
  NOTIFICATION_STEPS = ENV['NOTIFICATION_STEPS'].split(',').map(&:to_i)

  User.all.each do |user|

    next unless user.pushbullet_token
    birthdays_x_day  = []

    ::Contact.all.select { |c| c.nb_days_before_next_birthday.in? NOTIFICATION_STEPS }.each do |contact|
      next_birthday = contact.next_birthday
      user          = contact.user
      birthdays_x_day << {name: contact.name, date: next_birthday[:date], number_days: next_birthday[:day_number], x_days: contact.nb_days_before_next_birthday}
    end

    push = SendPush.new(user.pushbullet_token.access_token, user.pushbullet_token.device)
    push.send_birthdays_x_day(birthdays_x_day)
  end
end

