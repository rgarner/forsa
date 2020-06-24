class SubscriptionRate
  BASE_PERCENTAGE     = (0.8).freeze
  CLERICAL_PERCENTAGE = (1.0).freeze

  ANNUAL_CAP       = 48450.freeze

  DEEMED_WEEKS     = 52.freeze
  DEEMED_MONTHS    = 12.freeze

  attr_reader :pay_rate, :pay_unit, :hours_per_week, :clerical_rate

  def initialize(pay_rate, pay_unit, hours_per_week: nil, clerical_rate: false)
    raise ArgumentError, 'pay_rate is required' if pay_rate.nil?
    raise ArgumentError, 'pay_unit is required' if pay_unit.nil?
    raise ArgumentError, "pay_unit of 'hour' given, hours_per_week required" if
      pay_unit == 'hour' && hours_per_week.blank?

    @pay_rate = BigDecimal(SubscriptionRate.sanitize_currency(pay_rate))
    @pay_unit = pay_unit
    @hours_per_week = BigDecimal(hours_per_week) if pay_unit == 'hour'
    @clerical_rate = clerical_rate
  end

  def percentage
    clerical_rate ? CLERICAL_PERCENTAGE : BASE_PERCENTAGE
  end

  ##
  # Return the monthly estimate as a formatted string
  def monthly_estimate
    '%0.2f' % monthly
  end

  def capped_annual_pay
    [annualised_pay_rate, ANNUAL_CAP].min
  end

  def annualised_pay_rate
    case pay_unit
    when 'year' then pay_rate
    when 'month' then pay_rate * DEEMED_MONTHS
    when 'fortnight' then pay_rate * DEEMED_WEEKS / 2
    when 'week' then pay_rate * DEEMED_WEEKS
    when 'hour' then pay_rate * hours_per_week * DEEMED_WEEKS
    else
      raise ArgumentError, "#{pay_unit.class} #{pay_unit} is not a valid pay_unit"
    end
  end

  ##
  # Monthly estimate as a decimal
  def monthly
    (capped_annual_pay * percentage / 100) / 12
  end

  def self.sanitize_currency(value)
    value.is_a?(String) ? value.gsub(/[£€,]/, '') : value
  end
end
