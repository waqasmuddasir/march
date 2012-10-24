desc "Insert default status messages"

task :add_group_numbers => :environment do
 puts "\n\nImport begins\n"
 begin
   GroupNumber.find_or_create({:group_name => "group1", :phone_number => "447537402608"})
   GroupNumber.find_or_create({:group_name => "group2", :phone_number => "447537402583"})
   GroupNumber.find_or_create({:group_name => "group3", :phone_number => "447537402584"})
   GroupNumber.find_or_create({:group_name => "group4", :phone_number => "447537402587"})
   GroupNumber.find_or_create({:group_name => "group5", :phone_number => "447537402591"})
   puts "\n\nImport ends\n"
 end
end


