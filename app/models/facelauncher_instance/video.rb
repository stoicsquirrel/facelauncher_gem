require 'httparty'

module FacelauncherInstance
  class Video
    include HTTParty
    base_uri FacelauncherInstance::Engine.config.server_url
    default_params program_id: FacelauncherInstance::Engine.config.program_id

    def self.all
      get("/videos.json")
    end

    def self.find(id)
      get("/videos.json/#{id}.json")
    end

    def self.find_by_photo_album_id(video_playlist_id)
      get("/videos.json", query: { video_playlist_id: video_playlist_id })
    end
  end
end
