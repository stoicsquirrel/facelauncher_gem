module FacelauncherInstance
  class Video < FacelauncherInstance::Model
    self.attributes = [
      :id, :program_id, :video_playlist_id, :embed_code, :embed_id, :title, :subtitle,
      :caption, :position, :screenshot, :created_at, :updated_at
    ]
  end
end
