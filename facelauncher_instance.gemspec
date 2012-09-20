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
  s.summary     = "The client instance for Facelauncher."
  s.description = "This gem allows the app to interface with Facelauncher, and provides the app with Facelauncher's built-in functionality."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "httparty", "~> 0.9.0"
  s.add_dependency "koala", "~> 1.5.0"
#  s.add_dependency "carrierwave", "~> 0.6.2"
#  s.add_dependency "cloudinary", "~> 1.0.35"
  # s.add_dependency "jquery-rails"
  # s.add_dependency "uglifier"
  # s.add_development_dependency "minitest-rails"
end
