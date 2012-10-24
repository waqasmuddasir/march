class Administration::AdminController < ApplicationController
  before_filter :authorize_admin, :except => [:login]
  before_filter :normal_admin_authorization, :only => [:change_password, :update_password]
  before_filter :super_admin_authorization, :only => [:update, :edit, :destroy, :create, :admin_user_index, :render_admin_user]
  before_filter :detect_browser
  before_filter :find_admin, :only=>[:destroy, :edit, :update, :update_password]
  layout "administration/admin"


  def index    
  end


 def login
    if !session[:admin_id].nil?
      redirect_to :action => :index
      return
    end
    if request.post?
      session[:admin_id]=nil
      @admin=Admin.authenticate(params[:admin][:login].to_s, params[:admin][:password].to_s)

      if @admin.blank?
        flash[:error]  = "Login or password incorrect"
      else

        if @admin.is_super
          session[:admin_type]="super_admin"
        end
        session[:admin_id]=@admin.login
        flash[:note]= "Hello #{session["login_id"].to_s} Welcome to admin panel"
        render :action=>:index
      end
    end
  end


  def logout
    session[:admin_id]=nil
    session[:admin_type]=nil
    flash[:error]  = "You have been Logged out of the system.."
    render :action => 'login'
  end




#------------------- Filters ----------------------------------

  def super_admin_authorization
       if session[:admin_type]!="super_admin"
        flash[:note]= "You are not authorized to access this page.."
        render :action=>:index
       end
  end


  def normal_admin_authorization
       if !session[:admin_type].blank? or session[:admin_type]=="admin"
        flash[:note]= "Unauthorized access.."
        render :action=>:index
       end
  end



  #---------------- for Super admin only -----------------------

  def admin_user_index
    @admins=Admin.all
    @admin=Admin.new
    render_admin_user
  end

  def render_admin_user
#     if session[:admin_type]=="super_admin"
      render :action => :admin_user_index
#     else
#       flash[:note]= "you are not authorized to access this page.."
#       render :action=>:index
#     end
  end


  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      flash[:error]  = "Admin Saved"
    else
      flash.now[:error]  = "Invalid Admin information"
    end
    admin_user_index
  end


  def destroy
    flash[:error]=@admin.login + "has been deleted.."
    @admin.destroy
    admin_user_index

  end

  def edit
    @admins=Admin.all
    @admin.password=""
    render_admin_user
  end


  def update
    
    if @admin.update_attributes(params[:admin])
      flash[:error]  = "Password changed successfully"
      admin_user_index
    else
      flash[:error]  = "Password could not be changed."
      @admins=Admin.all
      render_admin_user
    end
  end

  #---------------- for Normal admin only -----------------------


  def change_password
    
    @admin = Admin.find_by_login(session[:admin_id].to_s)
    render_change_password
  end


  def update_password
    
    if @admin.update_attributes(params[:admin])
      flash[:error]  = "New password updated"
    else
      flash[:error]  = "Password could not be changed."
    end
    render_change_password
  end

  def render_change_password
    @admin.password=""
    @admin.password_confirmation=""
    render :action => :change_password
  end

  private

  def find_admin
    @admin = Admin.find(params[:id])
  end
  
end
