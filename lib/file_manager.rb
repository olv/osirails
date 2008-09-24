class FileManager
  # Class method for upload a file to the server
  # options is a hash witch use the following symbol:
  # :file (it's the file to upload)
  # :directory (optional, it's a string contain the path, example: "public/upload")
  # :name (optional, it's a string to define the new name of the file)
  # :extensions (optional, it's an array of string where contains the allowed extensions, example: ["gif", "jpg"])
  # :file_type_id correspond to the id of a file_type
  def self.upload_file(options)
    return false if options[:file].nil?
    if options[:directory].nil?
      options[:directory] = "tmp/"
    end
    if options[:name].nil?
      name =  options[:file]['datafile'].original_filename + "." + File.mime_type?(File.open(options[:file][:datafile].path, "r"))
    else
      name = options[:name] + "." + File.mime_type?(File.open(options[:file][:datafile].path, "r"))
    end
    valid_extension = false
    
    unless options[:extensions].nil?
      options[:extensions].each do |extension|
        if name.end_with?("." + extension)
          valid_extension = true
        end
      end
      unless valid_extension
        return false
      end
    end
    
    ## Creation of path on server
    directory = ""
    options[:directory].split("/").each do |d|
      directory += d +"/"
      Dir.mkdir(directory) unless File.exist?(directory)
    end
    
    path = File.join(options[:directory], name)
    unless File.exist?(path)
      ## Test if mime_type correspond with possible extension
      #TODO change this code to integre a test for mime type like "- application /..."
      #FIXME When file uploaded is in text format, the file classs is UploadedStringIO instead of UploadedTempfile
      if self.valid_mime_type?(File.open(options[:file][:datafile].path, "r"), options[:file_type_id])
        File.open(path, "wb") { |f| f.write(options[:file][:datafile].read)}
        File.exist?(path)
      else
        FileManager.delete_file(path)
        return "Le mimetype du fichier n'est pas autoriser pour ce type de fichier"
      end
    end
  end
  
  def self.valid_mime_type?(file, file_type_id)
    extensions = []
    mime_type = File.mime_type?(File.open(((file.class == String) ? file : file.path), "r"))
    FileType.find(file_type_id).file_type_extensions.each{|extension| extensions << extension.name}
    return extensions.include?(mime_type)
  end
  
  def self.delete_file(file)
    FileUtils.rm_rf(file)
  end

end