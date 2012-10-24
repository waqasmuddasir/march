require 'rexml/document'
class Nontouch::SessionsController < Nontouch::SiteController
  #caches_action :new
  def index

  end
  def new
    if session[:auth_token] != nil
      redirect_to :controller => "packages", :action => "index"
    end
  end
  def create
    clear_loggedin_user
    url = URI.parse("#{Nontouch::SiteController::API_URL}/auth.xml")
    request = Net::HTTP::Post.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?><user><login>"+params[:session][:login]+"</login><password>"+params[:session][:password]+"</password></user>"
    request.content_type = 'text/xml'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    doc = REXML::Document.new(response.body )
    root = doc.root
    if root != nil && root.elements["code"].text == "200"
      session[:auth_token] = root.elements["user[1]/auth_token"].text
      session[:name] = root.elements["user[1]/name"].text
      session[:email] = root.elements["user[1]/email"].text
      redirect_to :controller => "packages", :action => "index"
      return
    elsif root.elements["code"].text == "401"
      flash[:error] = root.elements["detail"].text
      render :new
      return
    else
      flash[:error]="Invalid username/password"
      render :new
      return
    end
    render :new
  end
  def logout
    clear_loggedin_user
    render :new
  end
end
