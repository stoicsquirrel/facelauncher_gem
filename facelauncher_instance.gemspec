$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "facelauncher_instance/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "facelauncher_instance"
  s.version     = FacelauncherInstance::VERSION
  s.authors     = ["Alex Melman"]
  s.email       = ["alex.melman@bigfuel.com"]
  s.homepage    = "https://github.com/stoicsquirrel/facelauncher"
  s.summary     = "TODO: Summary of FacelauncherInstance."
  s.description = "TODO: Description of FacelauncherInstance."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  # s.add_dependency "jquery-rails"
  # s.add_dependency "uglifier"
  # s.add_development_dependency "pg"
  # s.add_development_dependency "minitest-rails"
end
