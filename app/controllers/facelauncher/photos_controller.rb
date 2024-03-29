require_dependency "facelauncher/application_controller"

module Facelauncher
  class PhotosController < ApplicationController
    layout 'application' # Use the application's layout instead of the gem's layout

    def index
      if params.key?(:photo_album_id)
        photo_album_id = params.key?(:albums) ? params[:albums] : params[:photo_album_id]
        @photos = Photo.find_by_photo_album_id(photo_album_id)
      else
        @photos = Photo.all # Facelauncher automatically gives you only items for the assigned program.
      end

      respond_to do |format|
        format.html
        format.json do
          if self.respond_to?('render_index_as_json')
            render_index_as_json
          else
            render json: @photos
          end
        end
      end
    end

    def show
      respond_to do |format|
        format.html do
          photo = Photo.find(params[:id])
          redirect_to(cl_image_path(File.basename(photo["file"]["url"])))
        end
      end
    end

    def redirect
      respond_to do |format|
        format.html do
          # Allow the app URL set in Facelauncher to be overridden using an env variable.
          app_url = ENV.key?('APP_URL') ? ENV['APP_URL'] : @program.program_app.app_url

          if app_url =~ /^https?\:\/\/www\.facebook\.com\//
            sep = !app_url.index('?').nil? ? '&' : '?'
            redirect_path = "#{app_url}#{sep}app_data=photo_#{params[:id]}"
            # Pass additional query string parameters to the redirect URL.
            redirect_path += '?' + request.env['QUERY_STRING'] if !request.env['QUERY_STRING'].blank?

            if !redirect_path.nil?
              redirect_to(redirect_path) if !redirect_path.nil?
            end
          else
            render 'redirect', :layout => false
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
