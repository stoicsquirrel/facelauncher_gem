module FacelauncherInstance
  class Video
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    attr_accessor :id, :program_id, :video_playlist_id, :embed_code, :embed_id, :title, :subtitle,
      :caption, :position, :screenshot, :created_at, :updated_at

    def initialize(attributes = {})
      self.attributes = attributes
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
      attributes = Rails.cache.fetch("/videos", :expires_in => cache_expiration) do
        attributes = {}
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http

          response = conn.get("/videos.json", { program_id: FacelauncherInstance::Engine.config.program_id })
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        videos = []
        attributes_for_all_videos = ActiveSupport::JSON.decode(attributes)
        attributes_for_all_videos.each do |attributes_for_video|
          videos << self.new(attributes_for_video)
        end
        videos
      end
    end

    def self.find(id)
      attributes = Rails.cache.fetch("/videos/#{id}", :expires_in => cache_expiration) do
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http

          response = conn.get("/videos/#{id}.json")
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        video = self.new.from_json(attributes, false)
      else
        raise ArgumentError, "Couldn't find Video with id=#{id}"
      end
    end

    def self.find_by_video_playlist_id(video_playlist_id)
      attributes = Rails.cache.fetch("/video_playlists/#{video_playlist_is}/videos", :expires_in => cache_expiration) do
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http

          response = conn.get("/videos.json", { video_playlist_id: video_playlist_id })
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        videos = []
        attributes_for_all_videos = ActiveSupport::JSON.decode(attributes)
        attributes_for_all_videos.each do |attributes_for_video|
          videos << self.new(attributes_for_video)
        end
        videos
      end
    end

    protected

    def self.cache_expiration
      FacelauncherInstance::Engine.config.respond_to?('cache_expiration') ? FacelauncherInstance::Engine.config.cache_expiration : 5.minutes
    end
  end
end
