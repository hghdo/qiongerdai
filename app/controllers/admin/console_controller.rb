class Admin::ConsoleController < ApplicationController
  before_filter :authorized?, :except => :install_summary
  layout 'console', :except => :install_summary
  layout 'application', :only => :install_summary
  
  def install_summary
    authenticate_or_request_with_http_basic do |login, password|
      if(login=='summary' && password='1234')
        sql="select count(*) as num, install_date_str as inst_date from devices group by install_date_str order by inst_date desc"
        @summaries=Device.find_by_sql(sql)
        respond_to do |format|
          format.html{ render :layout => false}   
        end
      else
        redirect_to root_path
      end
    end
  end
  
  
  def index
    @unverified_count=Archive.where("status=? or status=?",Archive::SYNCED,Archive::ANALYZED).count
    @locked_count=Archive.where("status=?",Archive::LOCKED).count
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @archives }
    end    
  end

  def admin_logout
    session[:admin]=false
    respond_to do |wants|
      wants.any {  redirect_to root_path }
    end
  end
  
  def authorized?
    return true if session[:admin]
    authenticate_or_request_with_http_basic do |login, password|
      if(login=='admin' && password='1234')
        session[:admin]=true
        redirect_to admin_console_path
      else
        session[:admin]=false
        redirect_to root_path
      end
    end
  end
  
  def login_from_basic_auth
    return true if session[:admin]
    #authenticate_with_http_basic 
    authenticate_or_request_with_http_basic do |login, password|
      if(login=='admin' && password='1234')
        session[:admin]=true
        redirect_to admin_console_path
      else
        session[:admin]=false
        redirect_to root_path
      end
    end
  end

end
