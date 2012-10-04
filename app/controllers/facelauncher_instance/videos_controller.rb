require_dependency "facelauncher_instance/application_controller"

module FacelauncherInstance
  class VideosController < ApplicationController
    layout 'application' # Use the application's layout instead of the gem's layout

    def index
      respond_to do |format|
        format.html do
          if params.key? :albums
            @videos = []
            params[:albums].each do |video_playlist_id|
              @videos += Video.find_by_video_playlist_id(video_playlist_id)
            end
          else
            @videos = Video.all
          end
        end
      end
    end

    def redirect
      respond_to do |format|
        format.html do
          app_url = ENV.key?('APP_URL') ? ENV['APP_URL'] : @program.app_url
          sep = !app_url.index('?').nil? ? '&' : '?'
          redirect_path = "#{app_url}#{sep}app_data=video_#{params[:id]}"
          # Pass additional query string parameters to the redirect URL.
          redirect_path += '?' + request.env['QUERY_STRING'] if !request.env['QUERY_STRING'].blank?

          if !redirect_path.nil?
            redirect_to(redirect_path) if !redirect_path.nil?
          end
        end
      end
    end
  end
end
