desc "Insert default sms messages"

task :import_sms_messages => :environment do
 puts "\n\nImport begins\n"
 begin
   Txtlocal.find_or_create({:sms_type => "redeem_link",  :message_contents => "Please click on following link to redeem your package"})
   Txtlocal.find_or_create({:sms_type => "reset_password",  :message_contents => "Please click on following link to reset your password"})
   Txtlocal.find_or_create({:sms_type => "group_chat",  :message_contents => " says: "})
   Txtlocal.find_or_create({:sms_type => "group_invitation",  :message_contents => " has invited "})
   puts "\n\nImport ends\n"
 end
end


