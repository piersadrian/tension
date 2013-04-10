$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'tension/version'

Gem::Specification.new do |s|
  s.name = "tension"

  s.version = Tension::VERSION
  s.date    = "2013-04-10"
  s.license = "MIT"

  s.summary     = "Tighten up Rails's asset pipeline for CSS & JS."
  s.description = "Tension brings some sanity to Rails's CSS & JS organization for modern front–end development."

  s.authors  = [ "Piers Mainwaring" ]
  s.email    = "piers@impossibly.org"
  s.files    = `git ls-files`.split("\n")
  s.homepage = "https://github.com/piersadrian/tension"
  s.require_paths = [ "lib" ]

  s.add_dependency "rails", ">= 3.2"
end
