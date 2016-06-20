# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "paranoia/version"

Gem::Specification.new do |gem|
  gem.name          = "paranoia"
  gem.version       = Paranoia::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["radarlistener@gmail.com"]
  gem.email         = []
  gem.homepage      = "http://rubygems.org/gems/paranoia"
  gem.license       = "MIT"
  gem.summary       = "Paranoia, light weight and configurable soft-delete gem for Rails 4."
  gem.description   = "Paranoia, light weight and configurable soft-delete gem for Rails 4. Use this gem if you wish that when you called destroy on an Active Record object that it didn't actually destroy it, but just \"hid\" the record. Paranoia does this by setting a deleted_at field to the current time when you destroy a record, and hides it by scoping all queries on your model to only include records which do not have a deleted_at field."

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.required_rubygems_version = ">= 1.3.6"
  gem.rubyforge_project         = "paranoia"

  gem.add_dependency "activerecord", ">= 4.1.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "byebug"
end
