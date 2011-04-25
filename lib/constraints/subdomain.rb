class Subdomain
  class << self
    def matches?(request)
      request.subdomain.present? && request.subdomain =~ /[0-9a-z-]{4,32}/
    end
  end
end
