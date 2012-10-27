# require 'httparty'
# 
# module FacelauncherInstance
#   class PhotoAlbum
#     include HTTParty
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

module FacelauncherInstance
  class PhotoAlbum
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    @@attributes = [
      :id, :program_id, :photos_attributes, :name, :sort_photos_by, :created_at, :updated_at
    ]
    @@attributes.each { |attr| attr_accessor attr }

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def attributes=(hash = {})
      unless hash.nil?
        hash.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end

    def attributes
      instance_values
    end

    def persisted?
      false
    end

    def photos
      FacelauncherInstance::Photo.find_by_photo_album_id(self.id)
    end

    def self.all(limit=nil, offset=nil)
      attributes = Rails.cache.fetch("/#{self.name.demodulize.underscore.pluralize}-#{cache_timestamp}", :expires_in => cache_expiration) do
        attributes = {}
        Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
          conn.adapter :net_http

          request_args = { program_id: FacelauncherInstance::Engine.config.program_id }
          request_args[:limit] = limit unless limit.nil?
          request_args[:offset] = offset unless offset.nil?

          response = conn.get("/#{self.name.demodulize.underscore.pluralize}.json", request_args)
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        items = []
        attributes_for_all_items = ActiveSupport::JSON.decode(attributes)
        attributes_for_all_items.each do |attributes_for_item|
          items << self.new(attributes_for_item)
        end
        items
      end
    end

#    def self.find(id, include_photos=false)
#      get("/photo_albums.json/#{id}.json", query: { include_photos: include_photos })
#    end
#
#    def self.find_by_name(name, include_photos=false)
#      get("/photo_albums.json", query: { name: name, include_photos: include_photos })
#    end

    private

    def self.cache_expiration
      FacelauncherInstance::Engine.config.respond_to?('cache_expiration') ? FacelauncherInstance::Engine.config.cache_expiration : 5.minutes
    end

    def self.cache_timestamp
      "12345" # Temporary until programs model is cached.
    end
  end
end
