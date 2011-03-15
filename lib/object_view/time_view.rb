class TimeView
  include ObjectView

  def initialize(time)
    @time = time
  end

  expose :@time, :year
  expose_by_dict :@time,
    :day => :day_of_month

end
