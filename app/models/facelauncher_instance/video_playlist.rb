require 'httparty'

module FacelauncherInstance
  class VideoPlaylist
    include HTTParty
    base_uri FacelauncherInstance::Engine.config.server_url
    default_params program_id: FacelauncherInstance::Engine.config.program_id

    def self.all(include_videos=false)
      get("/video_playlists.json", query: { include_videos: include_videos })
    end

    def self.find(id, include_videos=false)
      get("/video_playlists.json/#{id}.json", query: { include_videos: include_videos })
    end

    def self.find_by_name(name, include_videos=false)
      get("/video_playlists.json", query: { name: name, include_videos: include_videos })
    end
  end
end
