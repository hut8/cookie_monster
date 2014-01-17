require 'rspec/autorun'
require 'pry'

def fixture_file(path)
  File.join(File.dirname(__FILE__), '..', 'fixtures', path)
end
