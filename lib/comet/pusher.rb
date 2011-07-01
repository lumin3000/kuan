module Comet::Pusher

  module ClassMethods
    def comet_channel(proc)
      define_method(:channel) {proc.call self}
    end
  end
  
  def self.included(host_class)
    host_class.extend(ClassMethods)
  end
  
  def push_to_comet(data)
    return if channel.blank? or data.blank?
    begin
      Rails.logger.info "COMET PUSH: #{data} on #{channel}"
      Juggernaut.publish(channel, data)
    rescue Exception => e
      Rails.logger.error "COMET ERROR: #{e.message}"
    end
  end

end
