require 'httparty'

module FacelauncherInstance
  class Photo
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :program_id, :photo_album_id, :file, :caption

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end

    def self.all
      Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
        conn.adapter :net_http
        conn.get("/photos.json")
      end
    end

    def self.find(id)
      Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
        conn.adapter :net_http
        conn.get("/photos.json/#{id}.json")
      end
    end

    def self.find_by_photo_album_id(photo_album_id)
      get("/photos.json", query: { photo_album_id: photo_album_id })
    end

    def self.create(params)
      # If there is no file attached, then return.
      if params.nil?
        return false
      # If there is a file of the correct type attached, then save it to the server, otherwise, just return.
      elsif params[:file].content_type =~ /^image\/(jpeg|gif|png)$/
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.request :multipart
          conn.request :url_encoded
          conn.adapter :net_http
          conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key

          FileUtils.mkdir_p("#{Rails.root}/tmp/images/uploaded") # Make the temp directory if one doesn't exist
          tmp_filename = "#{Rails.root}/tmp/images/uploaded/#{params[:file].original_filename}"
          FileUtils.copy(params[:file].path, tmp_filename)
          payload = { :photo => params }
          payload[:photo][:file] = Faraday::UploadIO.new(tmp_filename, params[:file].content_type)

          response = conn.post("/photos.json", payload)
          if response.status == 200
            return true
          end
        end
      end

      return false
    end
  end
end
