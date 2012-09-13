require 'httparty'

module FacelauncherInstance
  class Photo
    include HTTParty
    base_uri FacelauncherInstance::Engine.config.server_url
    default_params program_id: FacelauncherInstance::Engine.config.program_id

    def self.all
      get("/photos.json")
    end

    def self.find(id)
      get("/photos.json/#{id}.json")
    end

    def self.find_by_photo_album_id(photo_album_id)
      get("/photos.json", query: { photo_album_id: photo_album_id })
    end
  end
end


# module FacelauncherInstance
#   class Photo < ActiveResource::Base
#     self.site = FacelauncherInstance::Engine.config.server_url
#     self.format = :json
#
#     schema do
#       integer :program_id, :photo_album_id, :position
#       string :file, :title, :from_user_username, :from_user_full_name, :from_user_id,
#              :from_service, :from_twitter_image_service
#       text :caption
#     end
#   end
# end
