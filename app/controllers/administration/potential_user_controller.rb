class Administration::PotentialUserController < ApplicationController
  before_filter :authorize_admin
  before_filter :detect_browser
  layout "administration/admin"

  def index
      @page_count=PotentialUser.all.count/10
    if params[:page_number]
      @potential_users= PotentialUser.limit(10).offset(params[:page_number].to_i * 10)
      @current_page=params[:page_number]
    else
      @potential_users= PotentialUser.limit(10)
      @current_page=1
    end
    @search_type="index"
  end


  def search_by_area

    if !params[:area_id].nil?
      @potential_users= PotentialUser.find_all_by_area_id(params[:area_id])
      @page_count=@potential_users.count/10

      if params[:page_number]
        @potential_users= @potential_users.limit(10).offset(params[:page_number].to_i * 10)
        @current_page=params[:page_number]
      else

        if @potential_users.count>10
        @potential_users= @potential_users.limit(10)
        else
          @potential_users= @potential_users
        end
        @current_page=1
      end

    end

    @search_type="area"
    render :index, :area_id=>params[:area_id]
  end
end
