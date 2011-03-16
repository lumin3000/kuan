class Hash
  def deep_merge(another)
    deep_merger = proc {|key, v1, v2|
      (v1.is_a?(Hash) && v2.is_a?(Hash)) ? v1.merge(v2, &deep_merger) : v2
    }
    self.merge(another, &deep_merger)
  end
end
