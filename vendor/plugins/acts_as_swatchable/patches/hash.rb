class Hash
  def merge_if_override(other)
    self.merge(other){|key, val, otherval| if (not otherval.nil?); val = otherval; else; val = val end;  }
  end
end