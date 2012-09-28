require 'faraday_middleware'

module FacelauncherInstance
  class Photo
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :id, :program_id, :photo_album_id, :file, :caption, :username, :tags,
      :from_user_username, :from_user_full_name, :from_user_id, :from_service,
      :position, :from_twitter_image_service, :created_at, :updated_at

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
        conn.response :json, :content_type => /\bjson$/

        response = conn.get("/photos.json")
        return response.status == 200 ? response.body.with_indifferent_access : nil
      end
    end

    def self.find(id)
      Rails.cache.fetch("/photos/#{id}", :expires_in => 1.hour) do
        attributes = {}
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http
          conn.response :json, :content_type => /\bjson$/

          response = conn.get("/photos/#{id}.json")
          attributes = response.status == 200 ? response.body.with_indifferent_access : nil
        end

        if !attributes.nil?
          return self.new(attributes)
        else
          raise ArgumentError, "Couldn't find Photo with id=#{id}"
        end
      end
    end

    def self.find_by_photo_album_id(photo_album_id)
      Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
        conn.adapter :net_http
        conn.response :json, :content_type => /\bjson$/

        response = conn.get("/photos.json", { photo_album_id: photo_album_id })
        return response.status == 200 ? response.body.with_indifferent_access : nil
      end
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
