require 'yaml'
require 'sqlite3'

require_relative 'browser_descriptor.rb'

# CookieMonster implementation
# This class's public methods are the only ones needed by end users
class CookieMonster

  ###########################################################################
  # A "source" is a concrete instance of a CookieSource tied to a database
  # A "descriptor" contains instructions for the CookieSource to interpret
  #   a browser's cookie implementation, including paths, formats, etc.
  ###########################################################################

  # Parameters:
  # :browser => [required] from which browser are we loading cookies?
  # :descriptors => list of files to be executed as descriptors
  def initialize(options={})
    @options = options
    validate_options
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

  # def cookies_txt

  # end

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

  def validate_options
    unless @options[:browser]
      raise CookieMonsterError('No browser specified')
    end
  end

  ###################
  # Descriptor data #
  ###################

  # Mapping of :browser => Proc { |BrowserDescriptor| ... }
  def descriptors
    @descriptors ||= {}
  end

  # Load all the descriptors in the cookie-sources directory
  def load_descriptors
    glob = File.join(File.dirname(__FILE__), 'cookie-sources', '**', '*.rb')
    Dir.glob(glob).each do |descriptor_file|
      instance_eval File.read(descriptor_file)
    end
  end

  # Find and invoke the descriptor DSL for use by a CookieSource
  def invoke_descriptor(browser)
    descriptor = descriptors[browser]
    unless descriptor
      raise CookieMonsterError, "Could not find descriptor for #{browser.to_s}"
    end
    res = BrowserDescriptor.new
    descriptor.call(res)
    res
  end

  # Make a concrete CookieSource using a loaded descriptor
  def make_source
    raise CookieMonsterParameterError, 'No browser specified' unless @options[:browser]
    @source = invoke_descriptor(@options[:browser])
    if @options[:source_db_path]
      @source.db_path = options[:source_db_path]
    else
      @source.find_db
    end
    # At this point we have a concrete cookie source
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
    candidates = Dir.glob(File.expand_path(@descriptor.default_db_path))
    if candidates.length == 1
      candidates.first
    elsif candidates.length > 1
      raise CookieMonsterException, "Ambiguous DB match: #{candidates.inspect}"
    else
      raise CookieMonsterException, 'Could not find cookie database'
    end
  end

  ##
  # Return an Enumerable of Cookies
  def cookies

  end
end

class CookieMonsterError < StandardError; end
class CookieMonsterParameterError < ArgumentError; end
