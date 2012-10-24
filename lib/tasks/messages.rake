desc "Insert default status messages"

task :import_messages => :environment do
 puts "\n\nImport begins\n"
 begin
   Api::Message.find_or_create({:status => "Ok", :code => 200, :detail => ""})
   Api::Message.find_or_create({:status => "Created", :code => 201, :detail => ""})
   Api::Message.find_or_create({:status => "Bad request", :code => 400, :detail => ""})
   Api::Message.find_or_create({:status => "Unauthorized", :code => 401, :detail => ""})
   Api::Message.find_or_create({:status => "Not found", :code => 404, :detail => ""})
   Api::Message.find_or_create({:status => "Forbidden", :code => 403, :detail => ""})
   puts "\n\nImport ends\n"
 end
end


