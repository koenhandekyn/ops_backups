require_relative "lib/ops/backups/version"

Gem::Specification.new do |spec|
  spec.name        = "ops_backups"
  spec.version     = Ops::Backups::VERSION
  spec.authors     = [ "Koen Handekyn" ]
  spec.email       = [ "github.com@handekyn.com" ]
  spec.homepage    = "https://github.com/koenhandekyn/ops-backups"
  spec.summary     = "A Ruby gem for managing PostgreSQL backups."
  spec.description = "This gem provides functionality to backup PostgreSQL databases to ActiveStorage (S3) from within a Rails context."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/koenhandekyn/ops-backups/tree/main"
  spec.metadata["changelog_uri"] = "https://github.com/koenhandekyn/ops-backups/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6"
end
