Gem::Specification.new do |s|
  s.name        = 'cookie_monster'
  s.version     = '0.0.1'
  s.date        = '2013-12-16'
  s.summary     = "Query browser cookie databases"
  s.description = "Easily access data in cookies from Firefox and Chrome"
  s.authors     = ["Liam Bowen"]
  s.email       = 'liambowen@gmail.com'
  s.files       = Dir.glob(File.join(File.dirname(__FILE__), "**/*.rb")) + ['README.md']
  s.homepage    =
    'http://github.com/bowenl2/cookie_monster'
  s.license       = 'MIT'
end
