require 'yaml'
require 'openstruct'

class Cookie < OpenStruct
  attr_accessible(:domain, :expires, :http_only, :name,
                  :path, :secure, :value)
end

class CookieMonster
  def initialize(options={})
    @options = options
    validate_options
    make_source
  end

  private

  def validate_options
    unless @options[:browser]
      raise CookieMonsterParameterError('No browser specified')
    end
  end

  def make_source
    @source = case @options[:browser]
              when :firefox then FirefoxCookieSource.new
              when :chrome then ChromeCookieSource.new
              when :chromium then ChromiumCookieSource.new
              else nil
              end
    raise CookieMonsterException('Invalid :browser specified') unless @source
    if @options[:source_db_path]
      @source.db_path = options[:source_db_path]
    else
      @source.find_db
    end
    # At this point we have a concrete cookie source
  end
end

class FirefoxCookieSource < CookieSource
  # The schema from sqlite3
  # CREATE TABLE moz_cookies (id INTEGER PRIMARY KEY,
  #                           baseDomain TEXT,
  #                           appId INTEGER DEFAULT 0,
  #                           inBrowserElement INTEGER DEFAULT 0,
  #                           name TEXT,
  #                           value TEXT,
  #                           host TEXT,
  #                           path TEXT,
  #                           expiry INTEGER,
  #                           lastAccessed INTEGER,
  #                           creationTime INTEGER,
  #                           isSecure INTEGER,
  #                           isHttpOnly INTEGER,
  #                           CONSTRAINT moz_uniqueid UNIQUE (name, host, path, appId, inBrowserElement));
  # CREATE INDEX moz_basedomain ON moz_cookies (baseDomain, appId, inBrowserElement);

  @default_db_path = "~/.mozilla/**/cookies.sqlite"

  protected

  def process_row(row)
    col_map = {
      baseDomain: :domain,
      expiry: :expires,
      isHttpOnly: :http_only,
      name: :name,
      path: :path,
      isSecure: :secure,
      value: :value
    }
    Cookie.new(Hash[row.map { |k,v| [col_map[k], v] }])
  end
end

class ChromeCookieSource < CookieSource
  @default_db_path = "~/.config/google-chrome/**/Cookies"
end

class ChromiumCookieSource < CookieSource
  @default_db_path = "~/.config/chromium/**/Cookies"
end

class CookieSource
  attr_accessor :db_path

  class << self
    attr_reader :cookie_keys
  end

  @cookie_keys = [:domain, :expires, :http_only, :name,
                  :path,:secure, :shareable, :value]

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

  def process_row

  end
end

class CookieMonsterError < StandardError; end
class CookieMonsterParameterError < ArgumentError; end
