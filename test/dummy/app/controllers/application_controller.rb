class ApplicationController < FacelauncherInstance::ApplicationController
  before_filter :before_index, :only => :index

  def before_index
    @photo = FacelauncherInstance::Photo.new
  end

  protected
  def before_parse_app_data(app_data)

  end
end
