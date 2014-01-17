require 'yaml'
require 'sqlite3'

# CookieMonster implementation
# This class's public methods are the only ones needed by end users
class CookieMonster
  attr_accessor :descriptor_globs

  ###########################################################################
  # A "source" is a concrete instance of a CookieSource tied to a database
  # A "descriptor" contains instructions for the CookieSource to interpret
  #   a browser's cookie implementation, including paths, formats, etc.
  ###########################################################################

  # Parameters:
  # :browser          => [required] from which browser are we loading cookies?
  # :descriptor_globs => list of globs to be executed as descriptors
  # :database_path    => pass an exact path to the cookie database
  def initialize(options={})
    @options = options
    load_descriptors
    make_source
  end

  def loaded_browsers
    descriptors.keys
  end

  ######################
  # Serializer methods #
  ######################

  # The format that a 'Cookie' header uses in HTTP
  # key-name: value-thereof; other-key: other value;
  def http
    cookies.map { |c| "#{c.name}: #{c.value}" }.join('; ')
  end

  def cookies_txt
    cookies.map do |c|
      [c.host, c.host.startwith?(".").to_s.upcase, c.path,
       c.secure.to_s.upcase, c.expiration.to_i, c.name, c.value].join("\t")
    end.join("\n")
  end

  # def mechanize

  # end

  # # Httparty::CookieHash
  # def httparty_cookie_hash

  # end

  protected

  # DSL method for defining a browser
  def define(browser, &block)
    descriptors[browser] = block
  end

  private

  ###################
  # Descriptor data #
  ###################

  # Mapping of :browser => Proc { |BrowserDescriptor| ... }
  def descriptors
    @descriptors ||= {}
  end

  # Load all the descriptors in the cookie-sources directory
  def load_descriptors
    if @options[:descriptor_globs]
      @descriptor_globs = @options[:descriptor_globs]
    else
      @descriptor_globs = [File.join(File.dirname(__FILE__), 'cookie-sources', '**', '*.rb')]
    end
    Dir.glob(*descriptor_globs).each do |descriptor_file|
      instance_eval File.read(descriptor_file)
    end
  end

  # Find and invoke the descriptor DSL for use by a CookieSource
  def invoke_descriptor(browser)
    descriptor = descriptors[browser]
    unless descriptor
      path_msg = @descriptor_globs.join(', ')
      raise CookieMonsterError,
      "Could not find descriptor for #{browser.to_s} (searched #{path_msg})"
    end
    res = BrowserDescriptor.new
    descriptor.call(res)
    res
  end

  # Make a concrete CookieSource using a loaded descriptor
  def make_source
    raise CookieMonsterError, 'No browser specified' unless @options[:browser]
    @descriptor = invoke_descriptor(@options[:browser])
    @source = CookieSource.new(@descriptor)
    if @options[:source_db_path]
      @source.db_path = @options[:source_db_path]
    else
      @source.find_db
    end
    # Rejoice!  @source is now a CookieSource
  end
end


module SqliteCookieSourceMethods
  def each_raw_cookie(filter={})
    query = "SELECT #{select_clause} FROM #{table}"
    sqlite_source
  end

  def sqlite_source
    @sqlite_source ||= SQLite3::Database.new(db_path)
  end

  private

  def select_clause
    @select_clause ||= self.class.cookie_keys.map do |key|
      "#{@transformers[key].column_name} AS #{key.to_s}"
    end.join(', ')
  end
end

class Fixnum
  def to_bool
    self != 0
  end
end

class CookieSource
  include SqliteCookieSourceMethods

  def initialize(descriptor)
    @descriptor = descriptor
  end

  attr_accessor :domain_filter, :path_filter
  attr_writer :db_path
  COOKIE_KEYS = [:domain, :expires, :http_only, :name,
                 :path, :secure, :shareable, :value]

  def db_path
    @db_path ||= find_db
  end

  def find_db
    candidates = Dir.glob(File.expand_path(@descriptor.default_db_paths))
    if candidates.length == 1
      candidates.first
    elsif candidates.length > 1
      raise CookieMonsterError, "Ambiguous DB match: #{candidates.inspect}"
    else
      raise CookieMonsterError, "Could not find cookie database (searched #{@descriptor.default_db_paths})"
    end
  end

  # Enumerable of Cookies
  def cookies

  end
end

class CookieMonsterError < StandardError; end
