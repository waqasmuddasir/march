class DataFile < ActiveRecord::Base
  
  def self.extract_csv(upload)
    name =  "temp_csv"
    directory = "public/data"      # create the file path
    path = File.join(directory, name)
    
    save upload, path
    csv=""
    if File::exists?( path )
      file = File.new(path, 'r')
      file.each_line("\n") do |row|
        csv= csv + row.chomp + ", "
        csv=csv.gsub("'","")
        csv=csv.gsub('"','')
      end
    end
    csv=csv.chop.chop
    cleanup path #delete file
    return csv
  end

  def self.save before_upload_file, after_upload_path
    # write the file
    File.open(after_upload_path, "wb") { |f| f.write(before_upload_file['datafile'].read)}
  end
  
  private
  def self.cleanup path
    File.delete("#{path}") if File.exist?("#{path}")            
  end

  def remove_extra_bits csv
   csv[0..csv.length-1]
  end
end
