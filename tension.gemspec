Gem::Specification.new do |s|
  s.name = "tension"

  s.version = "0.3"
  s.date    = "2013-02-22"

  s.summary     = "Tighten up Rails's asset pipeline for CSS & JS."
  s.description = "Tension brings some sanity to CSS & JS organization for modern front–end development."

  s.authors  = [ "Piers Mainwaring" ]
  s.email    = "piers@impossibly.org"
  s.files    = `git ls-files`.split("\n")
  s.homepage = "https://github.com/piersadrian/tension"
  s.require_paths = [ "lib" ]

  s.add_dependency "activerecord",  "~> 3.2.0"
  s.add_dependency "activesupport", "~> 3.2.0"
end
