require 'rspec/autorun'
require 'pry'

def fixture_file(path)
  File.realpath(File.join(File.dirname(__FILE__), '..', 'fixtures', path))
end
