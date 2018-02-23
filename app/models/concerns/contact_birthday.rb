module ContactBirthday
  def nb_days_before_next_birthday
    (next_birthday[:date] - Date.today).to_i
  end

  def next_birthday
    birthdays.reject { |x| x[:date] < Date.today }.first
  end

  def birthdays
    BirthdayCalculator.birthdays(self.birthday)
  end
end
