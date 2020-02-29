require "date"
require File.expand_path("../lib/kishu/version", __FILE__)


Gem::Specification.new do |spec|
  spec.name          = "kishu"
  spec.version       = Kishu::VERSION
  spec.authors       = ["Kristian Garza"]
  spec.email         = ["kgarza@datacite.org"]

  spec.summary       = "Client for DOI Resolution Logs processing pipeline"
  spec.description   = "This client helps you to prepare logs to be consumed for the pipeline as well as for creating DOI resolution reports using the COUNTER CoP "
  spec.homepage      = "https://github.com/datacite/kishu"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.

  # spec.add_dependency 'maremma', '>= 4.1', '< 5'
  spec.add_dependency 'faraday', "~>0.15.3"
  spec.add_dependency 'builder', '~> 3.2', '>= 3.2.2'
  spec.add_dependency 'dotenv', '~> 2.1', '>= 2.1.1'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'maremma', '>= 4.1', '< 5'
  spec.add_dependency 'faraday_middleware-aws-sigv4', '~> 0.2.4'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'elasticsearch', '~> 6.1.0'
  spec.add_development_dependency "thor", '~> 0.19'
  spec.add_development_dependency "faraday", "~>0.15.3"
  spec.add_development_dependency 'rack-test', '~> 0'
  spec.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.3'
  spec.add_development_dependency 'webmock', '~> 3.0', '>= 3.0.1'
  spec.add_development_dependency 'simplecov', '~> 0.14.1'
  spec.add_development_dependency 'factory_bot', '~> 4.0'
  spec.add_dependency 'sucker_punch', '~> 2.0'
  spec.add_dependency 'bolognese', '~> 0.9', '>= 0.10'
  spec.add_dependency 'elasticsearch', '~> 6.1.0'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = ["kishu"]
  spec.require_paths = ["lib"]
end
