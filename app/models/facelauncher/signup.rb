module Facelauncher
  class Signup < ActiveResource::Base
    self.site = Facelauncher::Engine.config.server_url
    self.format = :json

    schema do
      string :email, :first_name, :last_name, :city, :zip, :facebook_user_id,
             :program_access_key
    end

    validates :email, presence: true, length: { maximum: 100 }
    validates :first_name, length: { maximum: 50 }
    validates :last_name, length: { maximum: 50 }
    validates :city, length: { maximum: 40 }
    validates :zip, length: { maximum: 9 }
    validates :facebook_user_id, length: { maximum: 25 }
  end
end
