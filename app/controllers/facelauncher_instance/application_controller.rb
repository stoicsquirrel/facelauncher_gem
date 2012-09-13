module FacelauncherInstance
  class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :get_program

    def index
      respond_to do |format|
        format.html
      end
    end

    private
    def get_program
      begin
        @program = FacelauncherInstance::Program.find(FacelauncherInstance::Engine.config.program_id)
      rescue ActiveResource::ResourceNotFound
        raise ActionController::RoutingError.new('Not Found')
      end
      if @program.active
        @photo_albums = FacelauncherInstance::PhotoAlbum.all(true) #find(:all, params: { program_id: FacelauncherInstance::Engine.config.program_id })
        binding.pry

        # Add the photos and the filenames to the photo_album objects.
        @photo_albums.each do |photo_album|
          if !photo_album["approved_photos"].nil?
            photo_album["photos"] = photo_album.delete("approved_photos")
            photo_album["photos"].each do |photo|
              photo["file"]["filename"] = File.basename(photo["file"]["url"])
            end
          end
        end
      else
        # If the program is inactive, then render the application's "inactive" template.
        # If the application did not define an "inactive" template, then show an HTTP 503 error.
        begin
          render :inactive, layout: false unless @program.active
        rescue ActionView::MissingTemplate
          render file: 'public/503.html', format: :html, status: '503'
        end
      end

      # rescue
        # render file: 'public/503', format: :html, status: '503'
      #  raise "error"
    end
  end
end
