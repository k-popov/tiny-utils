"""
Usage:

    ncat -l 127.0.0.1 8082 -c 'ruby xkcd.rb'
    links2 -g http://127.0.0.1:8082/
"""

require 'json'
require 'open-uri'
require 'restclient'
require 'RMagick'

include Magick

stat = JSON.parse RestClient.get(
    'http://xkcd.com/info.0.json',
    :accept => 'application/json'
)
comic_idx = Random.new.rand(1..stat['num'])
# comic_idx = 1411 # this was good for ALT testing
comic = JSON.parse RestClient.get(
    "http://xkcd.com/#{comic_idx}/info.0.json",
    :accept => 'application/json'
)

image_blob = "" # store image BLOB here
fd = open(comic['img'])
while (chunk = fd.read 1024)
    image_blob << chunk
end
fd.close()


# create an Image object from what we have read from XKCD site
base = Image.from_blob(image_blob).first()
# create an image for title
# TODO find a way to calculate *correct* font size
title_font_height = Integer(base.columns / comic['safe_title'].length / 0.8)
title_image = Image.new(base.columns, title_font_height + 6) { self.background_color = "white"}
# create an image for alt text
alt_image = Image.new(base.columns, 100) { self.background_color = "white"}
# draw a narrow separator lone
separator = Magick::Draw.new()
separator.stroke("black")
separator.stroke_width(1)
separator.line(0, 5, base.columns, 5)
separator.draw(alt_image)

# set up fonts and size
text = Magick::Draw.new
# text.font_family = 'helvetica'
text.font_family = 'Courier'
text.pointsize = title_font_height
#text.pointsize = 45
text.gravity = Magick::CenterGravity

# draw title on its image
text.annotate(title_image, 0, 0, 0, 0, comic['safe_title']) { self.fill = "black" }

# prepare new font
text.pointsize = 12
text.gravity = Magick::WestGravity
# TODO Find a way to split words, not characters
# split text so it could fit image margins
alt_text_array = []
# TODO find a way to calculate font size
step = Integer(base.columns / 8) # 8 here is character width
(0..comic['alt'].length).step(step) do |s|
    alt_text_array << comic['alt'][s .. s + (step-1)]
end
alt_text_split = alt_text_array.join("\n")
# draw alt on its image
text.annotate(alt_image, 0, 0, 5, 5, alt_text_split) { self.fill = "black" }

# combine XKCD, Title and Alt into one image
combination_list = ImageList.new()
combination_list << title_image
combination_list << base
combination_list << alt_image

combination = combination_list.append(true)
combination.format = 'PNG'

# useful for local debug
# combination.display()


puts <<EOF
HTTP/1.1 200 OK
Content-Type: image/png

EOF
$stdout.write(combination.to_blob())
