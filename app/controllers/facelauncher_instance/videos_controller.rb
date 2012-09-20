require_dependency "facelauncher_instance/application_controller"

module FacelauncherInstance
  class VideosController < ApplicationController
    def show
      respond_to do |format|
        app_url = ENV.key?('APP_URL') ? ENV['APP_URL'] : @program.app_url
        redirect_path = "#{app_url}&app_data=video_#{params[:id]}"

        format.html do
          if !redirect_path.nil?
            redirect_to(redirect_path) if !redirect_path.nil?
          end
        end
      end
    end
  end
end
