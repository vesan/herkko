# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'herkko/version'

Gem::Specification.new do |spec|
  spec.name          = "herkko"
  spec.version       = Herkko::VERSION
  spec.authors       = ["Vesa Vänskä"]
  spec.email         = ["vesa@vesavanska.com"]

  spec.summary       = %q{Herkko is a deployment tool for Heroku.}
  spec.description   = %q{It's highly opinionated and might not suit your needs. It has certain conventions you need to follow, but it also provides great user experience based on those conventions.}
  spec.homepage      = "https://github.com/vesan/herkko"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
