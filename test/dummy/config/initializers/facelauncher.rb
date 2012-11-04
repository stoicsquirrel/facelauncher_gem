# Be sure to restart your server when you modify this file.
Facelauncher::Engine.configure do
  config.server_url = "http://localhost:5000/"

  # The program_id and program_access_key fields are required in order to
  # have access to the Facelauncher API.
  config.program_id = 1
  config.program_access_key = "09dc5a1505d04fddaa6cca8355e118c1"
  config.cache_expiration = 1.minute
end
