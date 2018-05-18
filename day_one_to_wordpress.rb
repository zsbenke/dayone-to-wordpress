require "rubypress"
require "mime/types"
require "json"
require 'time'

# change the following values
export_path = "path/to/your/day-one-json-archive"
json = File.read("#{export_path}/your_journal.json")
host = "yourblog.com"
username = "wordpress_username"
password = "wordpress_password"

Photo = Struct.new(:img, :identifier)
wp = Rubypress::Client.new(:host => host, username: username, password: password)
photos_path = "#{export_path}/photos"
journal = JSON.parse(json)
entries = journal['entries']

entries.each do |entry|
  photos = entry['photos']
  uploaded_photos = []

  unless photos.nil?
    photos.each do |photo|
      name = photo['md5']
      type = photo['type']
      identifier = photo['identifier']
      filename = "#{photos_path}/#{name}.#{type}"

      if File.exist?(filename)
        puts filename
        uploaded_photo = wp.uploadFile(data: {
          name: "#{name}.#{type}",
          type: MIME::Types.type_for(filename).first.to_s,
          bits: XMLRPC::Base64.new(IO.read(filename))
        })
        link = uploaded_photo['link']
        uploaded_photos << Photo.new("<img src=\"#{link}\">", identifier)
      else
        puts "file not found"
      end
    end
  end

  location = entry['location']
  latitude = nil
  longitude = nil
  locality_name = nil
  country = nil
  place_name = nil
  administrative_area = nil

  unless location.nil?
    latitude = location['latitude']
    longitude = location['longitude']
    country = location['country']
    locality_name = location['localityName']
    place_name = location['placeName']
    administrative_area = location['administrativeArea']
  end

  created_at = Time.parse(entry['creationDate'])
  text = "#{entry['text']}"
  tags = entry['tags']

  uploaded_photos.each do |photo|
    text = text.gsub(/\!\[\]\(dayone-moment\:\/\/#{photo.identifier}\)/, photo.img)
  end

  content = {
    post_status: "private",
    post_date:  created_at,
    post_content: text,
    post_title: created_at.strftime("%Y-%m-%d %H:%M"),
    post_name: created_at.strftime("%Y-%m-%d-%H%M"),
    post_author: 1
  }

  unless location.nil?
    custom_fields = []
    custom_fields << { key: 'latitude', value: latitude } unless latitude.nil?
    custom_fields << { key: 'longitude', value: longitude } unless longitude.nil?
    custom_fields << { key: 'country', value: country } unless country.nil?
    custom_fields << { key: 'locality_name', value: locality_name } unless locality_name.nil?
    custom_fields << { key: 'place_name', value: place_name } unless place_name.nil?
    custom_fields << { key: 'administrative_area', value: administrative_area } unless administrative_area.nil?

    content['custom_fields'] = custom_fields
  end

  if tags.nil?
    content['terms_names'] = {
      category: ['Private']
    }
  else
    content['terms_names'] = {
      category: ['Private'],
      post_tag: tags
    }
  end

  uploaded_post = wp.newPost(
    blog_id: 0,
    content: content
  )

  puts """
  lat: #{latitude}
  long: #{longitude}
  text: #{text}
  created_at: #{created_at}
  """

end


