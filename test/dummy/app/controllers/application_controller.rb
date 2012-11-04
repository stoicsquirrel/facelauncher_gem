class ApplicationController < Facelauncher::ApplicationController
  before_filter :before_index, :only => :index

  def before_index
    @photo_album = Facelauncher::PhotoAlbum.find(1)
    @video_playlist = Facelauncher::VideoPlaylist.find(1)
  end

  protected
  def before_parse_app_data(app_data)

  end
end
