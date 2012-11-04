module Facelauncher
  class Video < Facelauncher::Model
    self.attributes = [
      :id, :program_id, :tags, :video_playlist_id, :embed_code, :embed_id, :title, :subtitle,
      :caption, :position, :screenshot, :created_at, :updated_at
    ]

    #def tags
    #  Facelauncher::VideoTag.find_by_video_id(self.id)
    #end
  end
end
