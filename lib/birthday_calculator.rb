class BirthdayCalculator
  DATES = ((1..40).to_a.map { |x| x * 1_000 } + [11111, 22222, 33333, 44444]).freeze

  def self.birthdays(birthday)
    @instance = new(birthday)
    DATES.map { |date| {day_number: date, date: @instance.x_days_date(date)} }
  end

  def initialize(birthday)
    raise ArgumentError.new("Birthday must be a Date") unless birthday.is_a? Date
    @birthday = birthday
  end

  def x_days_date(x)
    @birthday.next_day(x)
  end
end
