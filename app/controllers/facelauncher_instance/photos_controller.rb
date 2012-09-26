require_dependency "facelauncher_instance/application_controller"

module FacelauncherInstance
  class PhotosController < ApplicationController

    def show
      respond_to do |format|
        format.html do
          photo = Photo.find(params[:id])
          redirect_to(cl_image_path(File.basename(photo["file"]["url"])))
        end
      end
    end

    # TODO: Add a check for a program parameter determining if this is a Facebook redirect.
    def redirect
      app_url = ENV.key?('APP_URL') ? ENV['APP_URL'] : @program.app_url
      sep = app_url =~ '?' ? '&' : '?'
      redirect_path = "#{app_url}#{sep}app_data=photo_#{params[:id]}"

      respond_to do |format|
        format.html do
          if !redirect_path.nil?
            redirect_to(redirect_path) if !redirect_path.nil?
          end
        end
      end
    end

    def new
      respond_to do |format|
        @photo = Photo.new
        format.html { render :action => :new }
      end
    end

    def create
      respond_to do |format|
        response = Photo.create(params[:photo])

        if response
          format.html { redirect_to new_photo_path, :notice => 'Your photo was saved successfully.' }
        else
          flash[:alert] = 'Your photo could not be saved at this time.'
          format.html { render :action => :new }
        end
      end
    end
  end
end
