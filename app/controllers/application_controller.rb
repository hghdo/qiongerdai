class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prepare_for_mobile
  before_filter :hot_archives

  def hot_archives
    @hot_archives=Archive.where(["status=?",Archive::OK]).order("pub_date desc").limit(8)
  end

  private
  def mobile?
    if session[:mobile_param]
      session[:mobile_param]=='1'
    else
      request.user_agent=~/Mobile|webOS/
    end
  end
  helper_method :mobile?

  def prepare_for_mobile
    session[:mobile_param]=params[:mobile] if params[:mobile]
    request.format=:mobile if mobile?
  end
end
