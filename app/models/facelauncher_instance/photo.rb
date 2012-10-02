# require 'faraday_middleware'

module FacelauncherInstance
  class Photo
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    attr_accessor :id, :program_id, :photo_album_id, :file, :caption, :username, :tags,
      :from_user_username, :from_user_full_name, :from_user_id, :from_service,
      :position, :from_twitter_image_service, :created_at, :updated_at

    def initialize(attributes = {})
      self.attributes = attributes

      # attributes.each do |name, value|
      #   if name == 'created_at' || name == 'updated_at'
      #     send("#{name}=", value.to_time)
      #   else
      #     send("#{name}=", value)
      #   end
      # end
    end

    def attributes=(hash)
      hash.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def attributes
      instance_values
    end

    def persisted?
      false
    end

    def self.all
      attributes = Rails.cache.fetch("/photos", :expires_in => cache_expiration) do
        attributes = {}
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http
          #conn.response :json, :content_type => /\bjson$/

          response = conn.get("/photos.json", { program_id: FacelauncherInstance::Engine.config.program_id })
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        photos = []
        attributes_for_all_photos = ActiveSupport::JSON.decode(attributes)
        attributes_for_all_photos.each do |attributes_for_photo|
          photos << self.new(attributes_for_photo)
        end
        photos
      end
    end

    def self.find(id)
      attributes = Rails.cache.fetch("/photos/#{id}", :expires_in => cache_expiration) do
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http
          #conn.response :json, :content_type => /\bjson$/

          response = conn.get("/photos/#{id}.json")
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        photo = self.new.from_json(attributes, false)
      else
        raise ArgumentError, "Couldn't find Photo with id=#{id}"
      end
    end

    def self.find_by_photo_album_id(photo_album_id)
      attributes = Rails.cache.fetch("/photo_albums/#{photo_album_id}/photos", :expires_in => cache_expiration) do
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http
          #conn.response :json, :content_type => /\bjson$/

          response = conn.get("/photos.json", { photo_album_id: photo_album_id })
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        photos = []
        attributes_for_all_photos = ActiveSupport::JSON.decode(attributes)
        attributes_for_all_photos.each do |attributes_for_photo|
          photos << self.new(attributes_for_photo)
        end
        photos
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

    protected

    def self.cache_expiration
      FacelauncherInstance::Engine.config.respond_to?('cache_expiration') ? FacelauncherInstance::Engine.config.cache_expiration : 30.minutes
    end
  end
end
