module FacelauncherInstance
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

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

    def self.all(limit=nil, offset=nil)
      class_name = self.name.demodulize.underscore.pluralize
      attributes = Rails.cache.fetch("/#{class_name}-#{cache_timestamp}", :expires_in => cache_expiration) do
        attributes = {}
        Faraday.new(:url => self.facelauncher_url) do |conn|
          conn.adapter :net_http

          request_args = { program_id: self.facelauncher_program_id }
          request_args[:limit] = limit unless limit.nil?
          request_args[:offset] = offset unless offset.nil?

          response = conn.get("/#{class_name}.json", request_args)
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

    def self.find(id)
      class_name = self.name.demodulize.underscore.pluralize
      attributes = Rails.cache.fetch("/#{class_name}/#{id}-#{cache_timestamp}", :expires_in => cache_expiration) do
        Faraday.new(:url => self.facelauncher_url) do |conn|
          conn.adapter :net_http

          response = conn.get("/#{class_name}/#{id}.json")
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        photo = self.new.from_json(attributes, false)
      else
        raise ArgumentError, "Couldn't find Photo with id=#{id}"
      end
    end

    def self.facelauncher_url
      ENV.key?('FACELAUNCHER_URL') ? ENV['FACELAUNCHER_URL'] : FacelauncherInstance::Engine.config.server_url
    end

    def self.facelauncher_program_id
      ENV.key?('FACELAUNCHER_PROGRAM_ID') ? ENV['FACELAUNCHER_PROGRAM_ID'] : FacelauncherInstance::Engine.config.program_id
    end

    def self.facelauncher_program_access_key
      ENV.key?('FACELAUNCHER_PROGRAM_ACCESS_KEY') ? ENV['FACELAUNCHER_PROGRAM_ACCESS_KEY'] : FacelauncherInstance::Engine.config.program_access_key
    end

    protected

    def self.attributes=(*attributes)
      @@attributes = attributes.flatten
      @@attributes.each do |attribute|
        attr_accessor attribute
        
        self.class.send :define_method, "find_by_#{attribute}" do |value|
          class_name = self.name.demodulize.underscore.pluralize
          attributes = Rails.cache.fetch("/#{class_name}/find_by_#{attribute}/#{value.to_s.underscore}-#{cache_timestamp}", :expires_in => cache_expiration) do
            Faraday.new(:url => self.facelauncher_url) do |conn|
              conn.adapter :net_http

              response = conn.get("/#{class_name}.json", { attribute => value })
              attributes = response.status == 200 ? response.body : nil
            end
            attributes
          end

          if !attributes.nil?
            ActiveSupport.parse_json_times = true

            items = []
            attributes_for_all_photos = ActiveSupport::JSON.decode(attributes)
            attributes_for_all_photos.each do |attributes_for_item|
              items << self.new(attributes_for_item)
            end
            items
          end
        end
      end
    end

    def self.cache_expiration
      FacelauncherInstance::Engine.config.respond_to?('cache_expiration') ? FacelauncherInstance::Engine.config.cache_expiration : 5.minutes
    end

    def self.cache_timestamp
      "12345" # Temporary until programs model is cached.
    end
  end
end