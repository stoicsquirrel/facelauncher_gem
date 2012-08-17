module FacelauncherInstance
  class InstallGenerator < Rails::Generators::Base
    #source_root File.expand_path('../templates', __FILE__)

    def create_initializer_file
      puts 'Generating initialization file...'
      program_id = ask "What is the Facelauncher program's ID?"
      program_access_key = ask "What is the access key for this Facelauncher key?"
      initializer "facelauncher.rb" do
%{# Be sure to restart your server when you modify this file.
FacelauncherInstance.setup do |config|
  # The program_id and program_access_key fields are required in order to
  # have access to the Facelauncher API.
  config.program_id = #{program_id}
  config.program_access_key = "#{program_access_key}"
end
}
      end

      puts 'Generating templates...'
      create_file 'public/503.html' do
<<-eof
<!DOCTYPE html>
<html>
<head>
  <title>We're sorry, but the page is currently unavailable (503)</title>
  <style type="text/css">
    body { background-color: #fff; color: #666; text-align: center; font-family: arial, sans-serif; }
    div.dialog {
      width: 25em;
      padding: 0 4em;
      margin: 4em auto 0 auto;
      border: 1px solid #ccc;
      border-right-color: #999;
      border-bottom-color: #999;
    }
    h1 { font-size: 100%; color: #f00; line-height: 1.5em; }
  </style>
</head>

<body>
  <!-- This file lives in public/500.html -->
  <div class="dialog">
    <h1>We're sorry, but the page is currently unavailable.</h1>
  </div>
</body>
</html>
eof
      end
    end
  end
end
