module FacelauncherInstance
  class InstallGenerator < Rails::Generators::Base
    #source_root File.expand_path('../templates', __FILE__)

    def create_initializer_files
      puts "Please answer the following two questions about your app:"
      program_id = ask "What is ID of this program in Facelauncher?" || 0
      program_access_key = ask "What is the access key for this Facelauncher program?" || ''
      has_cloudinary = ask "Are you using Cloudinary? (Y or N)" : 'Y'
      puts "Generating initialization files..."
      initializer "facelauncher.rb" do
%{# Be sure to restart your server when you modify this file.
FacelauncherInstance::Engine.configure do
  config.server_url = "http://localhost:5000/"

  # The program_id and program_access_key fields are required in order to
  # have access to the Facelauncher API.
  config.program_id = #{program_id}
  config.program_access_key = '#{program_access_key}'
end

}
      end

      if has_cloudinary.upcase == 'Y'
        create_file "config/cloudinary.yml" do
<<-END
# Replace this with your cloudinary.yml file.
---
development:
  cloud_name:
  api_key:
  api_secret:
  enhance_image_tag: true
  static_image_support: false
production:
  cloud_name:
  api_key:
  api_secret:
  enhance_image_tag: true
  static_image_support: true
test:
  cloud_name:
  api_key:
  api_secret:
  enhance_image_tag: true
  static_image_support: false

END
        end

        gem('cloudinary', version: '1.0.35')
        gem('koala', version: '1.5.0')
      end
    end

    def create_template_files
      puts 'Generating templates...'
      create_file 'public/503.html' do
<<-END
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
  <!-- This file lives in public/503.html -->
  <div class="dialog">
    <h1>We're sorry, but the page is currently unavailable.</h1>
  </div>
</body>
</html>

END
      end
    end
  end
end
