module FacelauncherInstance
  class ApplicationController < ActionController::Base
    protect_from_forgery
    #layout "facelauncher_instance/application"
    before_filter :get_program

    def index
      respond_to do |format|
        format.html
      end
    end

    private
    def get_program
      begin
        @program = FacelauncherInstance::Program.find(FacelauncherInstance.program_id)
        @photos = FacelauncherInstance::Photo.all
        if !Cloudinary.nil?
          @cl_photo_names = Array.new
          @photos.each do |photo|
            matches = /[^\/\s]+.(jpg|jpeg|png|gif)$/.match(photo.file.url)
            if !matches.nil?
              @cl_photo_names << matches[0]
            end
          end
        end
      rescue ActiveResource::ResourceNotFound
        raise ActionController::RoutingError.new('Not Found')
      # rescue
        # render file: 'public/503', format: :html, status: '503'
      #  raise "error"
      end

      # If the program is inactive, then render the application's "inactive" template.
      # If the application did not define an "inactive" template, then show an HTTP 503 error.
      begin
        render :inactive, layout: false unless @program.active
      rescue ActionView::MissingTemplate
        render file: 'public/503.html', format: :html, status: '503'
      end
    end
  end
end
