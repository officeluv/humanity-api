# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'humanity_api/version'

Gem::Specification.new do |spec|
  spec.name          = "humanity_api"
  spec.version       = HumanityApi::VERSION
  spec.authors       = ["Jane Kim"]
  spec.email         = ["jane@officeluv.com"]

  spec.summary       = %q{This gem allows access to the Humanity API using Ruby.}
  spec.description   = %q{The Humanity API gem allows users to access the Humanity API with a simple set of parameters.}
  spec.homepage      = "https://github.com/officeluv/humanity-api"
  spec.license       = "GNU"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
