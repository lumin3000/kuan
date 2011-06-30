module Comet::Config
  def self.included(host_class)
    host_class.before_filter :load_comet_config
  end

  def load_comet_config
    @comet_config = YAML.load_file("#{Rails.root}/config/comet.yml")[Rails.env]
    uri = URI.parse("http://#{@comet_config["server"]}")
    @comet_config["host"] ||= uri.host
    @comet_config["port"] ||= uri.port
  end
end
