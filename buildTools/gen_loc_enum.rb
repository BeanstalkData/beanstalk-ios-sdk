require 'json'

loc_file_path = ""
enum_file_path = ""
enum_name = "LocKey"

loc_file_prefix = "--locfile="
enum_file_prefix = "--enums="
enum_name_prefix = "--enums_name="

ARGV.each do |a|
  if a.start_with? loc_file_prefix
    loc_file_path = a[loc_file_prefix.length .. a.length - 1]
  elsif a.start_with? enum_file_prefix
    enum_file_path = a[enum_file_prefix.length .. a.length - 1]
  elsif a.start_with? enum_name_prefix
    enum_name = a[enum_name_prefix.length .. a.length - 1]
  end
end

print "\n"
print "locfile=#{loc_file_path}\n"
print "enums=#{enum_file_path}\n"
print "enum_name=#{enum_name}\n"
print "\n"

args_valid = true
if loc_file_path == ""
  print "specify '#{loc_file_prefix}'\n"
  args_valid = false
end
if enum_file_path == ""
  print "specify '#{enum_file_prefix}'\n"
  args_valid = false
end
if !args_valid
  print "\n"
  exit 0
end


loc_file_content = File.open(loc_file_path).read

enum_file_content = "/* Auto-generated */\n\nimport Foundation\n\nenum #{enum_name}: String, BELocKeyProtocol {\n\
  public func getRawValue() -> String {\n\
    return self.rawValue \n\
  }  \n  \n"
loc_file_content.each_line do |line|
  line_striped = line.strip
  if line_striped.start_with? "/*"
    next
  elsif line_striped.length == 0
    next
  end
  
  key_part = line_striped.split('=').first.strip
  
  enum_key = key_part[1 .. key_part.length - 2]
  
  enum_file_content += "  case #{enum_key} = #{key_part}\n"
end
enum_file_content += "}\n"

File.write(enum_file_path, enum_file_content)
