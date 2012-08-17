class ApplicationController < FacelauncherInstance::ApplicationController
  #layout "facelauncher_instance/application"

  def index
    respond_to do |format|
      format.html
    end
  end
end
