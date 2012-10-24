class OfferedPackagesController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_required
  layout "users"
  def current
    @packages=current_user.current_packages

  end

  def past
    @packages=current_user.past_packages
  end

  def future
    @packages=current_user.future_packages
  end

  def show
    @package=current_user.subscribed_package?(params[:id])
    if !@package
      flash[:error]="You are not subscribed for this package.."
    end
  end
  def  send_link_on_mobile
    @error = ""
    if !current_user.nil? && !current_user.mobile.blank?
      @error = current_user.send_package_link_text(params[:id])
    else
      @error = "You've not provided your number."
    end
  end
  

 
  def offer_redeemed_by_email
    package=Administration::MerchantPackage.find(params[:id].to_i)
    if package.send_redemption_link(current_user)
      flash[:notice]  = " An Email has been sent to your account.."
    else
      flash[:error]  = " Link cannot be sent due to missin information, please report.."
    end
    redirect_to :action=>"current"
  end
end
