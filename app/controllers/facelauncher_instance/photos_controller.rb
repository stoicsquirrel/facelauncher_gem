require_dependency "facelauncher_instance/application_controller"

module FacelauncherInstance
  class PhotosController < ApplicationController
    def show
      respond_to do |format|
        # photo = Photo.find(params[:id])

        format.html do
          redirect_to(path_to_photo) if !path_to_photo.nil?
        end
      end
    end
  end
end
