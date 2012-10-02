require 'httparty'

module FacelauncherInstance
  class PhotoAlbum
    include HTTParty
    base_uri FacelauncherInstance::Engine.config.server_url
    default_params program_id: FacelauncherInstance::Engine.config.program_id

    def self.all(include_photos=false)
      get("/photo_albums.json", query: { include_photos: include_photos })
    end

    def self.find(id, include_photos=false)
      get("/photo_albums.json/#{id}.json", query: { include_photos: include_photos })
    end

    def self.find_by_name(name, include_photos=false)
      get("/photo_albums.json", query: { name: name, include_photos: include_photos })
    end
  end
end

# require 'faraday_middleware'
#
# module FacelauncherInstance
#   class PhotoAlbum
#     extend ActiveModel::Naming
#     include ActiveModel::Conversion
#     include ActiveModel::Validations
#
#     attr_accessor
#
#     base_uri FacelauncherInstance::Engine.config.server_url
#     default_params program_id: FacelauncherInstance::Engine.config.program_id
#
#     def self.all(include_photos=false)
#       get("/photo_albums.json", query: { include_photos: include_photos })
#     end
#
#     def self.find(id, include_photos=false)
#       get("/photo_albums.json/#{id}.json", query: { include_photos: include_photos })
#     end
#
#     def self.find_by_name(name, include_photos=false)
#       get("/photo_albums.json", query: { name: name, include_photos: include_photos })
#     end
#   end
# end
