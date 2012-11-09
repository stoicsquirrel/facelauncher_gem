module Facelauncher
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

    def self.authentication_required_on(*methods)
      @authentication_required_on = methods.flatten
    end

    def self.authentication_required_on?(method)
      !@authentication_required_on.nil? && (@authentication_required_on.include?(method.to_sym) || @authentication_required_on.include?(method.to_s))
    end

    def self.all(limit=nil, offset=nil)
      class_name = self.name.demodulize.underscore.pluralize
      attributes = Rails.cache.fetch("/#{class_name}?limit=#{limit}&offset=#{offset}-#{cache_timestamp}", :expires_in => cache_expiration) do
        attributes = {}
        Faraday.new(:url => self.facelauncher_url) do |conn|
          conn.adapter :net_http
          if authentication_required_on? :all
            conn.basic_auth Facelauncher::Model.facelauncher_program_id, Facelauncher::Model.facelauncher_program_access_key
          end

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
          if authentication_required_on? :find
            conn.basic_auth Facelauncher::Model.facelauncher_program_id, Facelauncher::Model.facelauncher_program_access_key
          end

          response = conn.get("/#{class_name}/#{id}.json")
          attributes = response.status == 200 ? response.body : nil
        end
        attributes
      end

      if !attributes.nil?
        ActiveSupport.parse_json_times = true

        photo = self.new.from_json(attributes, false)
      else
        raise ArgumentError, "Couldn't find #{self.name.demodulize} with id=#{id}"
      end
    end

    def self.facelauncher_url
      if !defined? @@facelauncher_url
        @@facelauncher_url = ENV.key?('FACELAUNCHER_URL') ? ENV['FACELAUNCHER_URL'] : Facelauncher::Engine.config.server_url
      end

      @@facelauncher_url
    end

    def self.facelauncher_program_id
      if !defined? @@facelauncher_program_id
        @@facelauncher_program_id = ENV.key?('FACELAUNCHER_PROGRAM_ID') ? ENV['FACELAUNCHER_PROGRAM_ID'] : Facelauncher::Engine.config.program_id
      end

      @@facelauncher_program_id
    end

    def self.facelauncher_program_access_key
      if !defined? @@facelauncher_program_access_key
        @@facelauncher_program_access_key = ENV.key?('FACELAUNCHER_PROGRAM_ACCESS_KEY') ? ENV['FACELAUNCHER_PROGRAM_ACCESS_KEY'] : Facelauncher::Engine.config.program_access_key
      end

      @@facelauncher_program_access_key
    end

    def self.facelauncher_app_id
      if !defined? @@facelauncher_app_id
        @@facelauncher_app_id = ENV.key?('FACELAUNCHER_APP_ID') ? ENV['FACELAUNCHER_APP_ID'] : Facelauncher::Engine.config.program_app_id
      end

      @@facelauncher_app_id
    end

    #protected

    def self.attributes=(*attributes)
      attributes = attributes.flatten
      attributes.each do |attribute|
        attr_accessor attribute

        self.class.send :define_method, "find_by_#{attribute}" do |value|
          class_name = self.name.demodulize.underscore.pluralize
          attributes = Rails.cache.fetch("/#{class_name}/find_by_#{attribute}/#{value.to_s.underscore}-#{cache_timestamp}", :expires_in => cache_expiration) do
            Faraday.new(:url => self.facelauncher_url) do |conn|
              conn.adapter :net_http
              if authentication_required_on? "find_by_#{attribute}"
                conn.basic_auth Facelauncher::Model.facelauncher_program_id, Facelauncher::Model.facelauncher_program_access_key
              end

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

    def self.cache_expiration(duration=nil)
      if !duration.nil?
        @facelauncher_cache_expiration = duration
      elsif !defined? @facelauncher_cache_expiration
        if ENV.key?('FACELAUNCHER_CACHE_EXPIRATION')
          @facelauncher_cache_expiration = ENV['FACELAUNCHER_CACHE_EXPIRATION'].to_i
        elsif Facelauncher::Engine.config.respond_to?('cache_expiration')
          @facelauncher_cache_expiration = Facelauncher::Engine.config.cache_expiration
        else
          @facelauncher_cache_expiration = 5.minutes
        end
      end

      @facelauncher_cache_expiration
    end

    protected

    def self.cache_timestamp
      "12345" # Temporary until programs model is completed.
    end
  end
end