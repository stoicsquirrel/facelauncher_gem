module Facelauncher
  class VideoPlaylist < Facelauncher::Model
    self.attributes = [
      :id, :program_id, :photos_attributes, :name, :sort_videos_by, :created_at, :updated_at
    ]

    def videos
      Facelauncher::Video.find_by_video_playlist_id(self.id)
    end
  end
end
