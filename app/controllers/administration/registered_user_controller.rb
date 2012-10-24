class Administration::RegisteredUserController < ApplicationController
  before_filter :authorize_admin
  before_filter :detect_browser
  before_filter :find_user, :only=>[:show, :edit, :update]
  layout "administration/admin"

  def index
    @page_count=User.all.count/10
    if params[:page_number]
      #params[:page_number].to_i * 10
      @users= User.limit(10).offset(params[:page_number].to_i * 10)
      @current_page=params[:page_number]
    else
      @users= User.limit(10)
      @current_page=1
    end
    @search_type="index"
  end

  def search_by_name
    if !params[:name].nil?
      @users= User.where("name like '%#{params[:name]}%'")
    end
    render :index
  end

  def search_by_email
    if !params[:email].nil?
      @users= User.find_all_by_email(params[:email])
    end
    render :index
  end

  def search_by_package

    if !params[:package_id].nil?
      @users= User.list_by_package(params[:package_id])
      @page_count=@users.count/10

      if params[:page_number]
        @users= @users.limit(10).offset(params[:page_number].to_i * 10)
        @current_page=params[:page_number]
      else
        @users= @users.limit(10)
        @current_page=1
      end

    end

    @search_type="package"
    render :index, :package_id=>params[:package_id]

  end

  def edit
  end

  def show    
    @packages=User.find(params[:id]).all_packages
  end

  def update    
    @user.name=params[:user][:name]
    @user.email_notification=params[:user][:email_notification]
    @user.sms_notification=params[:user][:sms_notification]
    @user.mobile=params[:user][:mobile]
    success = @user && @user.save

    if success && @user.errors.empty?
      flash[:notice]="User New account settings has been saved."
    else
      flash[:notice]="Account settings has Not been Saved"
    end

    redirect_to :action => "show", :id=>@user.id
  end

  def update_password
    @user = User.find(params[:id])

    if ((params[:user][:password] == params[:user][:password_confirmation]) &&
          !params[:user][:password_confirmation].blank?)

      @user.password_confirmation = params[:user][:password_confirmation]
      @user.password = params[:user][:password]
      @user.password_changed?

      if @user.errors.count==0
        if @user.save(false)
          flash[:notice] = "Password successfully updated"
        else
          flash[:notice] = "Password not changed, invalid password "
        end
        redirect_to :action => :show, :id=>@user.id
      else

        err=""
        @user.errors.full_messages.each do |msg|
          err+=" - " + msg
        end

        flash[:notice] = "Password dose not change. "+ err
        redirect_to :action=>:change_password, :id=>@user.id
      end
    else
      flash[:notice] = "Password dose not match"
      redirect_to :action=>:change_password, :id=>@user.id
    end


  end

  def change_password
    @user = User.find(params[:id])
  end
################# User Package ####################


  def assign_package
    if !params[:package_id].blank? and !params[:user_id].blank?

        user=User.find(params[:user_id])
        if user.add_package(params[:package_id])
          user.send_package_link_email(params[:package_id])  if !params[:email_notification].nil?
          user.send_package_link_text(params[:package_id])  if !params[:sms_notification].nil?
          flash[:assign_package_notice]="Package subscribed."
        else 
          flash[:assign_package_notice]="Invalid Package or package already subscribed."
        end
    else
      flash[:assign_package_notice]="Invalid Package"
    end
    redirect_to :action => "show", :id=>params[:user_id]
  end

  def disassign_package
    if !params[:package_id].blank? and !params[:user_id].blank?
      #user_package=UserPackage.find_all_by_user_id_and_merchant_package_id(params[:package_id],params[:user_id])
      #user=User.find(params[:user_id])
      #user.user_packages.find(params[:package_id]).destroy
      UserPackage.destroy_all(:merchant_package_id => params[:package_id],:user_id => params[:user_id])
      flash[:assign_package_notice]="Package is removed from the user subscription."
    else
      flash[:assign_package_notice]="Invalid Package"
    end

    redirect_to :action => "show", :id=>params[:user_id]
  end

  def destroy
    if !params[:id].blank?
      UserPackage.destroy_all(:user_id => params[:id])
             User.destroy_all(:id => params[:id])
    end
    
    redirect_to :action => :index
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

end