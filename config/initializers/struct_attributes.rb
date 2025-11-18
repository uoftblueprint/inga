class Struct
  def attributes
    to_h.transform_keys(&:to_s)
  end
end
