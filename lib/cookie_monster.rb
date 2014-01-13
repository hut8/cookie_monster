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
              when :chrome then ChromiumCookieSource.new
              when :chromium then ChromiumCookieSource.new
              else nil
              end
    raise CookieMonster('') unless @source
    if options[:source_db_path]
      @source.db_path = options[:source_db_path]
    else
      @source.find_db
    end
  end
end

class FirefoxCookieSource < CookieSource
  def find_db
    raise CookieMonsterException('Could not find Firefox cookie database')
  end
end

class ChromiumCookieSource < CookieSource
  def find_db
    raise CookieMonsterException('Could not find Chromium cookie database')
  end
end

class CookieSource
  attr_accessor :db_path
end

class CookieMonsterError < StandardError; end
class CookieMonsterParameterError < ArgumentError; end
