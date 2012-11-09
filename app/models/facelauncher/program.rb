module Facelauncher
  class Program < Facelauncher::Model
    authentication_required_on :find
    cache_expiration(ENV.key?("FACELAUNCHER_PROGRAM_CACHE_EXPIRATION") ? ENV["FACELAUNCHER_PROGRAM_CACHE_EXPIRATION"] : 1.minute)

    self.attributes = [
      :id, :active, :name, :short_name, :description,
      :additional_info_1, :additional_info_2, :additional_info_3,
      :photos_updated_at, :videos_updated_at, :created_at, :updated_at
    ]

    def program_app(id=nil)
      id = Facelauncher::Model.facelauncher_app_id if id.nil?

      Facelauncher::ProgramApp.find(id)
    end
  end
end
