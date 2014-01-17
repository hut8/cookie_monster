
# Represents a single HTTP cookie
class Cookie
  attr_accessor(:domain, :expires, :http_only, :name,
                :path, :secure, :value)
  def current?
    if expires
      Time.now > expires
    else
      true # Session cookie?
    end
  end

  def expired?
    !current?
  end
end
