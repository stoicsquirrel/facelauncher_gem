# require 'faraday_middleware'

module FacelauncherInstance
  class Photo
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    @@attributes = [
      :id, :program_id, :photo_album_id, :file, :file_url, :caption,
      :username, :tags, :from_user_username, :from_user_full_name, :from_user_id,
      :from_service, :position, :from_twitter_image_service, :created_at, :updated_at
    ]
    @@attributes.each { |attr| attr_accessor attr }

    attr_accessor :id, :program_id, :photo_album_id, :file, :file_url, :caption,
      :username, :tags, :from_user_username, :from_user_full_name, :from_user_id,
      :from_service, :position, :from_twitter_image_service, :created_at, :updated_at

    validates :file_url, :presence => true, :if => "file.nil?"
    validates :file, :presence => true, :if => "file_url.nil?"

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def attributes=(hash = {})
      unless hash.nil?
        hash.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end

    def attributes
      instance_values
    end

    def persisted?
      false
    end

    def self.all
      attributes = Rails.cache.fetch("/photos-#{cache_timestamp}", :expires_in => cache_expiration) do
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
      attributes = Rails.cache.fetch("/photos/#{id}-#{cache_timestamp}", :expires_in => cache_expiration) do
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
      attributes = Rails.cache.fetch("/photo_albums/#{photo_album_id}/photos-#{cache_timestamp}", :expires_in => cache_expiration) do
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

    def self.create(params=nil)
      photo = self.new(params)
      photo.save

      return photo
    end

    def self.new(params=nil)
      if params.nil?
        super
      else
        # Select only model attributes from params to send as part of our request.
        params.select!{ |k,v| @@attributes.include?(k) }
        super(params)
      end
    end

    def save
      if self.valid?
        # If there is a file URL included, then send it off to the server for processing.
        if !self.file_url.nil?
          Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key

            response = conn.post("/photos.json", self.to_json)

            if response.status == 200
              return true
              # TODO: Add errors
            end
          end
        # URGENT: FILE UPLOADING THROUGH BROWSER NOW NEEDS TO BE RETESTED.
        # If there is a file of the correct type attached, then save it to the server, otherwise, just return.
        elsif !self.file.nil? && self.file.content_type =~ /^image\/(jpeg|gif|png)$/
          Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
            conn.request :multipart
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key

            FileUtils.mkdir_p("#{Rails.root}/tmp/images/uploaded") # Make the temp directory if one doesn't exist
            tmp_filename = "#{Rails.root}/tmp/images/uploaded/#{params[:photo][:file].original_filename}"
            # FileUtils.copy(params[:photo][:file].path, tmp_filename)
            payload = params
            # params[:photo][:file] = Faraday::UploadIO.new(tmp_filename, params[:photo][:file].content_type)

            response = conn.post("/photos.json", payload)
            if response.status == 200
              return true
              # TODO: Add errors
            end
          end
        end
      end

      return false
    end

    protected

    def self.cache_expiration
      FacelauncherInstance::Engine.config.respond_to?('cache_expiration') ? FacelauncherInstance::Engine.config.cache_expiration : 30.minutes
    end

    def self.cache_timestamp
      "12345" # Temporary until programs model is cached.
    end
  end
end
