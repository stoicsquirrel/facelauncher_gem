module FacelauncherInstance
  class PhotoAlbum
    self.attributes = [
      :id, :program_id, :photos_attributes, :name, :sort_photos_by, :created_at, :updated_at
    ]

    def photos
      FacelauncherInstance::Photo.find_by_photo_album_id(self.id)
    end
  end
end
