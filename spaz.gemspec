Gem::Specification.new do |s|
  s.name        = 'spaz'
  s.version     = '0.0.1'
  s.date        = '2015-01-24'
  s.summary     = "Twitch interactions through a shell tool"
  s.description = "Uses the Twitch provided API to report relevant data"
  s.authors     = ["Nick Herson"]
  s.email       = 'nicholas.herson@gmail.com'
  s.files       = ["lib/spaz.rb", "lib/spaz/spaz_configuration.rb"]
  s.homepage    =
    'http://github.com/nherson/spaz'
  s.license       = 'none'
  s.executables << 'spaz'
end
