module Comet::Pusher

  def push_to_comet(channels, data)
    return if channels.blank? or data.blank?
    begin
      Juggernaut.publish(channels, data)
    rescue Exception => e
      Rails.logger.error "COMET ERROR: #{e.message}"
    end
  end

end
