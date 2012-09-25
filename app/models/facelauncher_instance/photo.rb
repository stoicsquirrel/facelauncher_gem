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
      # If there is a file attached, then save it to the server, otherwise, just return.
      if !params[:file].nil?
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.request :multipart
          conn.request :url_encoded
          conn.adapter :net_http
          conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key

          FileUtils.copy(params[:file].path, params[:file].original_filename)
          payload = { :photo => params }
          payload[:photo][:file] = Faraday::UploadIO.new(params[:file].original_filename, params[:file].content_type)

          response = conn.post("/photos.json", payload)
          return response
        end
      end
    end
  end
end
