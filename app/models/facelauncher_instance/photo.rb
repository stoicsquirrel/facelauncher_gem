module FacelauncherInstance
  class Photo < FacelauncherInstance::Model
    self.attributes = [
      :id, :program_id, :photo_album_id, :file, :file_url, :caption,
      :username, :tags, :from_user_username, :from_user_full_name, :from_user_id,
      :from_service, :position, :from_twitter_image_service, :original_photo_id,
      :created_at, :updated_at, :additional_info_1, :additional_info_2,
      :additional_info_3
    ]

    validates :file_url, :presence => true, :if => "file.nil?"
    validates :file, :presence => true, :if => "file_url.nil?"

    def self.create(params=nil)
      photo = self.new(params)
      photo.save

      return photo
    end

    def save
      if self.valid?
        params = { :photo => attributes.select { |k,v| @@attributes.include?(k.to_sym) } }
        params[:photo][:program_id] = FacelauncherInstance::Engine.config.program_id

        # If there is a file URL included, then send it off to the server for processing.
        if !self.file_url.nil?
          Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key
            response = conn.post("/photos.json", params)

            if response.status == 200
              return true
              # TODO: Add errors
            end
          end
        # URGENT: FILE UPLOADING THROUGH BROWSER NOW NEEDS TO BE RETESTED.
        # If there is a file of the correct type attached, then save it to the server, otherwise, just return.
        elsif !self.file.nil? && self.file.content_type =~ /^image\/(jpeg|gif|png)$/
          Faraday.new(:url => FacelauncherInstance::Engine.config.server_url) do |conn|
            conn.request :multipart
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth FacelauncherInstance::Engine.config.program_id, FacelauncherInstance::Engine.config.program_access_key

            FileUtils.mkdir_p("#{Rails.root}/tmp/images/uploaded") # Make the temp directory if one doesn't exist
            tmp_filename = "#{Rails.root}/tmp/images/uploaded/#{params[:photo][:file].original_filename}"
            # FileUtils.copy(params[:photo][:file].path, tmp_filename)
            # params[:photo][:file] = Faraday::UploadIO.new(tmp_filename, params[:photo][:file].content_type)

            response = conn.post("/photos.json", params)
            if response.status == 200
              return true
              # TODO: Add errors
            end
          end
        end
      end

      return false
    end
  end
end
