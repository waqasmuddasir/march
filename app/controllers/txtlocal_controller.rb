class TxtlocalController < ApplicationController
   protect_from_forgery :only => [:create]
   skip_before_filter :verify_authenticity_token
   include Utils
  def new
    
  end
  def create
  
      group_chat = GroupChat.new
      group_chat.sender = params["sender"]
      group_chat.contents = params["content"]
      
      group_chat.in_number=strip_mobile!(params["inNumber"])

      group_chat.send_chat
      
    render :new
    
  end

end
