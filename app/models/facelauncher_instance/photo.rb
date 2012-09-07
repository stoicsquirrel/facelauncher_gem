module FacelauncherInstance
  class Photo < ActiveResource::Base
    self.site = "http://localhost:5000/"
    self.format = :json
    self.user = '1'
    self.password = '8f059923fccb3a15320b4716b92ad09a'

    schema do
      integer :program_id, :photo_album_id, :position
      string :file, :title, :from_user_username, :from_user_full_name, :from_user_id,
             :from_service, :from_twitter_image_service
      text :caption
    end
  end
end
