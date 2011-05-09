module LoggingHelper
  def general_log(name, *contents)
    raise 'No logging provided' if contents.empty?
    logger = Logger.new(Rails.root + "log/#{name}.log")
    content = ([Time.now] + contents).join " : "
    logger.info content
  end
end
