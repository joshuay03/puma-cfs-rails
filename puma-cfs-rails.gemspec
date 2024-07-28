# frozen_string_literal: true

require_relative "lib/puma_cfs_rails/version"

Gem::Specification.new do |spec|
  spec.name = "puma-cfs-rails"
  spec.version = PumaCFSRails::VERSION
  spec.authors = ["Joshua Young"]
  spec.email = ["djry1999@gmail.com"]

  spec.summary = "Middleware for a Puma Completely Fair Scheduler in the context of Rails"
  spec.homepage = "https://github.com/joshuay03/puma-cfs-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/README.md"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails", ">= 7.0"
end
