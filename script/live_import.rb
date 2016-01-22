csv_text = "event_type,name,link,city,country,organizer_id,cover_image_url
meetup,Hackster Live PHX,http://www.meetup.com/HacksterLivePHX,\"Phoenix, AZ\",United States,8388,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster Hardware Meetup - Seattle,http://www.meetup.com/Seattle-Arduino-Meetup,\"Seattle, WA\",United States,3475,https://c2.staticflickr.com/2/1552/24334006186_948d5fe58e_z.jpg
meetup,Hackster.io Meetup - Bulawayo,http://www.meetup.com/Bulawayo-Social-Meetup-BSM,Bulawayo,Zimbabwe,28536,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster Abuja,http://www.meetup.com/Hackster-Abuja/,Abuja,Nigeria,25045,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Robot Garden,http://www.meetup.com/Robot-Garden/,\"Livermore, CA\",United States,43155,http://photos4.meetupstatic.com/photos/event/6/0/8/0/600_443664704.jpeg
meetup,Makers Novi Sad,http://www.meetup.com/makers-ns,Novi Sad,Serbia,11436,http://photos4.meetupstatic.com/photos/event/5/5/7/7/600_439101879.jpeg
meetup,Hackster Hardware Meetup - DC,http://www.meetup.com/DC-VA-MD-Hackster/,\"Baltimore, MD\",United States,11775,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster Hardware Meetup En Bogotá,http://www.meetup.com/es-ES/Hackster-BOG/,Bogota,Colombia,23966,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster Hardware Meetup Hyderabad,http://www.meetup.com/Hackster-hyd/,Hyderabad,India,11041,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,TAP Lab - The Te Atatu Peninsula Makerspace,http://www.meetup.com/TAPLab/,Auckland,New Zealand,20599,http://photos4.meetupstatic.com/photos/event/b/1/e/a/600_442965546.jpeg
meetup,Hackster.io Hardware Meetup - Delhi NCR,http://www.meetup.com/Hackster-NCR/,Delhi,India,21154,http://photos1.meetupstatic.com/photos/event/e/0/c/f/600_433077551.jpeg
meetup,Hackster.io Hardware meetup - Guaymas,http://www.meetup.com/Hackster-io-Hardware-meetup-Guaymas/,Guaymas,Mexico,5239,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster.io - FoodValley - NL,http://www.meetup.com/Hackster-FoodValley-NL/,Wageningen,Netherlands,21113,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg
meetup,Hackster Hardware Meetup - Salt Lake City,Http://www.meetup.com/hackster-hardware-meetup-salt-lake-city,\"Salt Lake City, UT\",United States,13004,http://photos1.meetupstatic.com/photos/event/c/7/a/b/600_445851115.jpeg"

require 'csv'

csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  live = LiveChapter.new full_name: row['name'], event_type: row['event_type'], home_link: row['link'], city: row['city'], country: row['country']
  live.build_cover_image
  live.cover_image.remote_file_url = row['cover_image_url']
  live.members.new user_id: row['organizer_id'], group_roles: ['organizer']
  live.save
end