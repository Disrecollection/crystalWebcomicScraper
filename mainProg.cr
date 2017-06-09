# I got tired and it got a bit hacky as a result, but I also improved it from scraping just one site to being more universal.
require "crystagiri"
require "string_scanner"
puts "Hello."
puts "first comic, last comic, class name for next button, class name for commentary, class name for comic image."
latest_link = gets(chomp = true)
final_link = gets(chomp = true)
next_name = gets(chomp = true)
commentary_name = gets(chomp = true)
comic_name = gets(chomp = true)

# def start_loop
#  puts "Welcome. Please prepare to insert links."
#  puts "First, please enter the link of the first comic page."
#  latest_link = gets(chomp = true)
#  puts "Now, the last or latest comic page"
#  final_link = gets(chomp = true)
#  puts "Now, for a bit of sleuthing. Fetch me the name of the HTML class which surrounds the button that, when clicked, sends you to the next page."
#  next_name = gets(chomp = true)
#  puts "Now the name of the class which commentary or description is."
#  commentary_name = gets(chomp = true)
#  puts "Finally, bring me the class that the comic image itself is contained within."
#  comic_name = gets(chomp = true)
#  if latest_link.is_a?(String) && final_link.is_a?(String) && next_name.is_a?(String) && commentary_name.is_a?(String) && comic_name.is_a?(String)
#    puts "Alrighty, here we go."
#    return
#  else
#    puts "At least one of those wasn't a string. Somehow."
#    start_loop
#  end
# end

# start_loop
uber_count = 0
create_and_dir("crystalWebcomicScraperOutput")
if latest_link.is_a?(String) && final_link.is_a?(String) && next_name.is_a?(String) && commentary_name.is_a?(String) && comic_name.is_a?(String)
  while latest_link != final_link
    doc = Crystagiri::HTML.from_url(latest_link)
    dir_name = "nothing"
    doc.where_tag("title") { |tag| dir_name = tag.content }
    create_and_dir(dir_name)
    minicount = uber_count
    doc.where_class(commentary_name) do |tag|
      filename = minicount.to_s + "commentary"
      file_actual = File.open("#{filename}", "w")
      file_actual.write(tag.content.to_slice)
      file_actual.close
      minicount = minicount + 1
    end
    minicount = uber_count
    doc.where_class(comic_name) do |tag|
      filename = minicount.to_s + "comic"
      img_loc_raw = tag.node.to_xml
      img_loc_actual = obtain_url(img_loc_raw)
      file_blueprint = Crystagiri::HTML.from_url(img_loc_actual)
      file_actual = File.open(filename, "w")
      file_actual.write(file_blueprint.content.to_slice)
      file_actual.close
      minicount = minicount + 1
    end
    uber_count = uber_count + 1
    doc.where_class(next_name) do |tag|
      puts tag.node.to_xml
      latest_link = obtain_url(tag.node.to_xml)
    end
    Dir.cd("..")
    puts "One down, more to go."
    sleep 1
  end
else
  puts "One of those isn't a string."
end

def obtain_url(raw_xml : String)
  sscan = StringScanner.new(raw_xml)
  sscan.skip_until(/"http/)
  current_offset = sscan.offset
  new_offset = current_offset + 7 # String scanner is a lil bitch and when it scans // it inserts /:0/ between em. So therefore I gotta go thru trouble. 7 is the magic number needed ot bypass the HTTP://. which I then add in l8r.
  proto_url = sscan.scan_until(/"/)
  almost = {"http", proto_url}.join
  refined_url = almost.chomp(%("))
  puts refined_url
  if refined_url.is_a?(String)
    return refined_url
  else
    return raw_xml
  end
end

def create_and_dir(dir_name)
  Dir.mkdir_p(dir_name)
  Dir.cd(dir_name)
end

# Bar Hofesh suggested and coded the following instead of bloating up an omniHTML class. He also suggests a mark_and_retreat method.
# def create_and_dir(dir_name : String)
#  FileUtils.mkdir_p(dir_name)
#  Dir.cd("#{Dir.current}/#{dir_name}") if Dir.exists?("#{Dir.current}/#{dir_name}")
# end
# def mark_and_retreat
#  # HEre I need the method to retun the URL under "next" which is the url fo the next page in chronological order on the site.
#  qikdoc = Crystagiri::HTML.from_url(latest_link)
#  qikdoc.where_class(next_name) do |tag|
#    latest_link = obtain_url(tag.node.to_xml)
#  end
#  Dir.cd("..")
#  # and then also exit the current directory, so that the next time we run create_and_dir it doesn't make a new child in a non-master dir.
#  #	Dir.cd(..)
# end
