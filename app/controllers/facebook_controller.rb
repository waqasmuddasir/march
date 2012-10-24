class FacebookController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def canvas
    @potential_user= PotentialUser.new
  end
end
