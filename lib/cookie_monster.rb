require 'yaml'


class CookieMonster
  def initialize(options={})
    validate_options
    make_source(options)
  end

  private

  def validate_options
    unless options[:browser]
      raise CookieMonsterParameterError('No browser specified')
    end
  end

  def make_source(options)
    @source = case options[:browser]
              when :firefox then FirefoxCookieSource.new
              when :chrome then ChromeCookieSource.new
              when :chromium then ChromiumCookieSource.new
              else nil
              end
    raise CookieMonsterException('No :browser specified') unless @source
    if options[:source_db_path]
      @source.db_path = options[:source_db_path]
    else
      @source.find_db
    end
    # At this point we have a real cookie source
  end
end

class FirefoxCookieSource < CookieSource
  @@default_db_path = "~/.mozilla/**/cookies.sqlite"

end

class ChromeCookieSource < CookieSource
  @default_db_path = "~/.config/google-chrome/**/Cookies"
end

class ChromiumCookieSource < CookieSource
  @@default_db_path = "~/.config/chromium/**/Cookies"
end

class CookieSource
  attr_accessor :db_path
  def find_db
    candidates = Dir.glob(File.expand_path(self.class.default_db_path))
    if candidates.length == 1
      candidates.first
    elsif candidates.length > 1
      raise CookieMonsterException("Ambiguous DB match: #{candidates.inspect}")
    else
      raise CookieMonsterException('Could not find Chromium cookie database')
    end
  end
end

class CookieMonsterError < StandardError; end
class CookieMonsterParameterError < ArgumentError; end
