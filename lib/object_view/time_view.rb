# encoding: utf-8

class TimeView
  include ObjectView

  def initialize(time)
    @time = time
  end

  def self.expose_by_format(name, format)
    define_method name do
      @time.strftime format
    end
  end

  expose :@time, :year
  expose_by_dict :@time,
    :month => :month_number,
    :yday => :day_of_year,
    :day => :day_of_month,
    :min => :minutes,
    :sec => :seconds,
    :to_i => :timestamp

  DAY_OF_WEEK_NUM = [7,1,2,3,4,5,6]
  def day_of_week_number()
    DAY_OF_WEEK_NUM[@time.mday]
  end

  DAY_OF_WEEK_NUM_SC = ['日','一','二','三','四','五','六']
  def day_of_week_number_sc()
    DAY_OF_WEEK_NUM_SC[@time.wday]
  end

  def day_of_month_with_zero()
    '%02d' % day_of_month
  end

  def month_number_with_zero()
    '%02d' % month_number
  end

  { :day_of_week => '%A',
    :short_day_of_week => '%a',
    :week_of_year => '%U',
    :month => '%B',
    :short_month => '%b',
    :short_year => '%y',
    :am_pm => '%P',
    :capital_am_pm => '%p',
    :'12hour_with_zero' => '%H',
    :'24hour_with_zero' => '%I',
    :'12hour' => '%l',
    :'24hour' => '%k',
  }.each do |name, format|
    expose_by_format name, format
  end

  AM_PM_SC = {
    'am' => '上午',
    'pm' => '下午',
  }

  def am_pm_sc()
    AM_PM_SC[am_pm]
  end
end
