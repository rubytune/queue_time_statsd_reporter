
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "queue_time_statsd_reporter/version"

Gem::Specification.new do |spec|
  spec.name          = "queue_time_statsd_reporter"
  spec.version       = QueueTimeStatsdReporter::VERSION
  spec.authors       = ["Will Jessop"]
  spec.email         = ["will@willj.net"]

  spec.summary       = %q{Log HTTP request queue time to statsd}
  spec.description   = %q{Log HTTP request queue time to statsd when the HTTP_X_REQUEST_START is set.}
  spec.homepage      = "https://github.com/rubytune/queue_time_statsd_reporter"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack", "~> 2.0"
  spec.add_development_dependency "timecop", "~> 0.9"
end
