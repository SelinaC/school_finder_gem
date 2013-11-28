# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'school_finder/version'

Gem::Specification.new do |spec|
  spec.name          = "school_finder"
  spec.version       = SchoolFinder::VERSION
  spec.authors       = ["SelinaC"]
  spec.email         = ["selina.chotai@gmail.com"]
  spec.description   = %q{This gem finds school information and provides house price information in the area}
  spec.summary       = %q{provides house price information near a school}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
