Gem::Specification.new do |s|
  s.name = "tension"

  s.version = "0.3"
  s.date    = "2013-02-22"

  s.summary     = "Tighten up Rails's asset pipeline for CSS & JS."
  s.description = "Tension brings some sanity to Rails's CSS & JS organization for modern front–end development."

  s.authors  = [ "Piers Mainwaring" ]
  s.email    = "piers@impossibly.org"
  s.files    = `git ls-files`.split("\n")
  s.homepage = "https://github.com/piersadrian/tension"
  s.require_paths = [ "lib" ]

  s.add_dependency "rails", "~> 3.2"
end
