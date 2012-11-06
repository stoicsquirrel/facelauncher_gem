module Facelauncher
  class Photo < Facelauncher::Model
    self.attributes = [
      :id, :program_id, :photo_album_id, :file, :file_url, :caption,
      :username, :tags, :from_user_username, :from_user_full_name, :from_user_id,
      :from_service, :position, :from_twitter_image_service, :original_photo_id,
      :created_at, :updated_at, :additional_info_1, :additional_info_2,
      :additional_info_3
    ]

    validates :file_url, :presence => true, :if => "file.nil?"
    validates :file, :presence => true, :if => "file_url.nil?"

#    def tags
#      Facelauncher::PhotoTag.find_by_photo_id(self.id)
#    end

    def self.create(params=nil)
      photo = self.new(params)
      photo.save

      return photo
    end

    def save
      if self.valid?
        puts "All attributes: "
        puts attributes
        puts "Possible attributes: "
        puts @@attributes
        params = { :photo => attributes.select { |k,v| @@attributes.include?(k.to_sym) && k != 'file' } }
        puts "Selected attributes: "
        puts attributes.select { |k,v| @@attributes.include?(k.to_sym) && k != 'file' }

        params[:photo][:program_id] = Facelauncher::Model.facelauncher_program_id

        puts "Params: "
        puts params

        # If there is a file URL included, then send it off to the server for processing.
        if !self.file_url.nil?
          Faraday.new(:url => Facelauncher::Model.facelauncher_url) do |conn|
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth Facelauncher::Model.facelauncher_program_id, Facelauncher::Model.facelauncher_program_access_key
            response = conn.post("/photos.json", params)

            puts "Response: "
            puts "  Status: #{response.status}"
            puts "  Body: #{response.body}"

            if response.status == 200
              return true
              # TODO: Add errors
            end
          end
        # If there is a file of the correct type attached, then save it to the server, otherwise, just return.
        elsif !self.file.nil? && self.file.content_type =~ /^image\/(jpeg|gif|png)$/
          Faraday.new(:url => Facelauncher::Model.facelauncher_url) do |conn|
            conn.request :multipart
            conn.request :url_encoded
            conn.adapter :net_http
            conn.basic_auth Facelauncher::Model.facelauncher_program_id, Facelauncher::Model.facelauncher_program_access_key

            # Uncomment the following three lines and set the first parameter of Faraday::UploadIO.new 
            # to tmp_filename if you need the original file name.
            #FileUtils.mkdir_p("#{Rails.root}/tmp/images/uploaded") # Make the temp directory if one doesn't exist
            #tmp_filename = "#{Rails.root}/tmp/images/uploaded/#{attributes["file"].original_filename}"
            #FileUtils.copy(attributes["file"].path, tmp_filename)

            params[:photo][:file] = Faraday::UploadIO.new(attributes["file"].path, attributes["file"].content_type)
            
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
