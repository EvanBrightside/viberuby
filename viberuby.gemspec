lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viberuby/version'

Gem::Specification.new do |s|
  s.name          = 'viberuby'
  s.version       = Viberuby::VERSION
  s.authors       = ['EvanBrightside']
  s.email         = ['xvanx84@gmail.com']

  s.summary       = 'Viber bot api gem'
  s.description   = 'Simple Viber bot api'
  s.homepage      = 'http://ivanzabrodin.com'
  s.license       = 'MIT'

  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
