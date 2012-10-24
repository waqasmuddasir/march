desc "Insert default areas"

task :import_areas => :environment do
 puts "\n\nImport begins\n"
 begin
   Area.find_or_create({:name => "Covent Garden"})
   Area.find_or_create({:name => "Soho"})
   Area.find_or_create({:name => "Piccadilly"})
   Area.find_or_create({:name => "Holborn"})
   Area.find_or_create({:name => "Bloomsbury"})
   Area.find_or_create({:name => "Westminster"})
   Area.find_or_create({:name => "Mayfair"})
   Area.find_or_create({:name => "Knightsbridge"})
   Area.find_or_create({:name => "Marylebone"})
   Area.find_or_create({:name => "South Kensington"})
   Area.find_or_create({:name => "Notting Hill"})
   Area.find_or_create({:name => "Bayswater"})
   Area.find_or_create({:name => "Holland Park"})
   Area.find_or_create({:name => "St John's Wood"})
   Area.find_or_create({:name => "Camden Town"})
   Area.find_or_create({:name => "Islington"})
   Area.find_or_create({:name => "Clerkenwell"})
   Area.find_or_create({:name => "Fleet St"})
   Area.find_or_create({:name => "St. Paul's"})
   Area.find_or_create({:name => "Bank"})
   Area.find_or_create({:name => "Southwark"})
   Area.find_or_create({:name => "Waterloo"})
   Area.find_or_create({:name => "Shoreditch"})
   Area.find_or_create({:name => "Whitechapel"})
   Area.find_or_create({:name => "Tower Bridge"})
   Area.find_or_create({:name => "London Bridge"})
   Area.find_or_create({:name => "Canary Wharf"})
   Area.find_or_create({:name => "Chelsea"})
   Area.find_or_create({:name => "Battersea"})
   Area.find_or_create({:name => "Clapham"})
   Area.find_or_create({:name => "Balham"})
   Area.find_or_create({:name => "Vauxhall"})
   Area.find_or_create({:name => "Victoria"})
   Area.find_or_create({:name => "Putney"})
   Area.find_or_create({:name => "Fulham"})
  # Area.find_or_create({:name => "North London"})
  # Area.find_or_create({:name => "West London"})
  # Area.find_or_create({:name => "South London"})
  # Area.find_or_create({:name => "East London"})
   


   puts "\n\nImport ends\n"
 end
end
