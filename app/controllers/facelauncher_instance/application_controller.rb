module FacelauncherInstance
  class ApplicationController < ActionController::Base
    protect_from_forgery :except => :index
    before_filter :get_program

    def index
      respond_to do |format|
        if request.post?
          anchor = index_base
          if !anchor.nil?
            redirect_to(root_url(:anchor => anchor))
          else
            redirect_to(root_url)
          end
          return
        end

        format.html
      end
    end

    def index_base
      anchor = nil

      # Use static values stored in ENV, if they're defined.
      # This is useful for testing.
      facebook_app_id = ENV.key?('FACEBOOK_APP_ID') ? ENV['FACEBOOK_APP_ID'] : @program.facebook_app_id
      facebook_app_secret = ENV.key?('FACEBOOK_APP_SECRET') ? ENV['FACEBOOK_APP_SECRET'] : @program.facebook_app_secret

      fb_oauth = Koala::Facebook::OAuth.new(facebook_app_id, facebook_app_secret)
      if params.key? :signed_request
        fb_signed_request = fb_oauth.parse_signed_request(params[:signed_request])
        app_data = fb_signed_request.key?('app_data') ? fb_signed_request['app_data'] : nil

        if !app_data.nil?
          # Call an "event" to allow the app to use the FB app data on its own.
          anchor = before_parse_app_data(app_data) if self.respond_to?('before_parse_app_data')
          # If the event callback did not return an anchor (or doesn't exist), then do default
          # parsing for photo or video.
          if anchor.nil?
            app_data.match(/^(?<type>photo|video)_(?<id>\d+)/) do |match|
              anchor = "#{match[:type]}/#{match[:id]}"
            end
          end
        end
      end

      return anchor
    end

    private
    def get_program
      begin
        @program = FacelauncherInstance::Program.find(FacelauncherInstance::Engine.config.program_id)
      rescue ActiveResource::ResourceNotFound
        raise ActionController::RoutingError.new('Not Found')
      end
#      if @program.active
#        # Get photo albums with photos.
#        @photo_albums = FacelauncherInstance::PhotoAlbum.all(true)
#
#        # Add the photos and the filenames to the photo_album objects and rename approved_photos
#        # to photos.
#        @photo_albums.each do |photo_album|
#          if !photo_album["approved_photos"].nil?
#            photo_album["photos"] = photo_album.delete("approved_photos")
#            photo_album["photos"].each do |photo|
#              photo["file"]["filename"] = File.basename(photo["file"]["url"])
#            end
#          else
#            photo_album["photos"] = Hash.new
#          end
#        end
#
#        # Get video playlists with videos.
#        @video_playlists = FacelauncherInstance::VideoPlaylist.all(true)
#          # Add the videos and the filenames to the video_playlist objects and rename approved_videos
#          # to videos.
#          @video_playlists.each do |video_playlist|
#          video_playlist["videos"] = !video_playlist["approved_videos"].nil? ? video_playlist.delete("approved_videos") : Hash.new
#          video_playlist["videos"].each do |video|
#            video["screenshot"]["filename"] = !video["screenshot"]["url"].nil? ? File.basename(video["screenshot"]["url"]) : nil
#          end
#        end
#      else
#        # If the program is inactive, then render the application's "inactive" template.
#        # If the application did not define an "inactive" template, then show an HTTP 503 error.
#        begin
#          render :inactive, layout: false unless @program.active
#        rescue ActionView::MissingTemplate
#          render file: 'public/503.html', format: :html, status: '503'
#        end
#      end
#
#      # rescue
#        # render file: 'public/503', format: :html, status: '503'
#      #  raise "error"
    end
  end
end
