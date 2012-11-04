require_dependency "facelauncher/application_controller"

module Facelauncher
  class SignupsController < ApplicationController
    def create
      @signup = Signup.new(params[:signup])
      @signup.program_id = Facelauncher.setup.config.program_id
      @signup.program_access_key = Facelauncher.setup.config.program_access_key
      @signup.ip_address = request.ip

      respond_to do |format|
        if @signup.save
          #format.html { redirect_to @signup, notice: 'Signup was successfully created.' }
          format.html { render "SUCCESS!" }
        else
          format.html { render action: "new" }
          format.html { render "ERROR" }
        end
      end
    end
  end
end
