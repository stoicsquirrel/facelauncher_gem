# Facelauncher

A Ruby interface to the Facelauncher API.

## Installation
Facelauncher is currently served from its Git repository, so it is necessary to include the following in your Gemfile:

```sh
gem install facelauncher --git="https://bigfuel-deploy:bftech1@github.com/bigfuel/facelauncher_gem.git"
```

## Documentation
Link to come.

## Configuration
Facelauncher API v1.0 requires basic authentication using the application's program ID as the key, and program access key as the password.

The following global configuration options must be set in the `Facelauncher::Engine.configure` block, which should be placed in a file in your application's `config/initializers` directory.

```ruby
Facelauncher::Engine.configure do
  config.server_url = "http://bigfuel-facelauncher-staging.herokuapp.com/"

  # The program_id and program_access_key fields are required in order to
  # have access to the Facelauncher API.
  config.program_id = 2
  config.program_access_key = '6952389a5bb307d0bdc27eef956dae08'
  config.program_app_id = 2

  config.cache_expiration = 15.minutes
end
```

## Copyright
Copyright © 2012 Alex Melman, Big Fuel Communications LLC