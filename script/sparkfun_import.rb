platform = Platform.find_by_user_name 'sparkfun'
links_text = "https://www.sparkfun.com/products/12060
https://www.sparkfun.com/products/11021
https://www.sparkfun.com/products/11511
https://www.sparkfun.com/products/11113
https://www.sparkfun.com/products/13233
https://www.sparkfun.com/products/11061
https://www.sparkfun.com/products/12646
https://www.sparkfun.com/products/11812
https://www.sparkfun.com/products/13229
https://www.sparkfun.com/products/13097
https://www.sparkfun.com/products/12053
https://www.sparkfun.com/products/12757
https://www.sparkfun.com/products/9564
https://www.sparkfun.com/products/12697
https://www.sparkfun.com/products/9716
https://www.sparkfun.com/products/10414
https://www.sparkfun.com/products/10736
https://www.sparkfun.com/products/11114
https://www.sparkfun.com/products/9530
https://www.sparkfun.com/products/12857
https://www.sparkfun.com/products/11697
https://www.sparkfun.com/products/13167
https://www.sparkfun.com/products/11519
https://www.sparkfun.com/products/13297
https://www.sparkfun.com/products/10822
https://www.sparkfun.com/products/9873
https://www.sparkfun.com/products/8665
https://www.sparkfun.com/products/13025
https://www.sparkfun.com/products/11215
https://www.sparkfun.com/products/13001
https://www.sparkfun.com/products/8942
https://www.sparkfun.com/products/10969
https://www.sparkfun.com/products/12923
https://www.sparkfun.com/products/8742
https://www.sparkfun.com/products/8606
https://www.sparkfun.com/products/13024
https://www.sparkfun.com/products/9238
https://www.sparkfun.com/products/11486
https://www.sparkfun.com/products/12651
https://www.sparkfun.com/products/11704
https://www.sparkfun.com/products/11287
https://www.sparkfun.com/products/10573
https://www.sparkfun.com/products/11262
https://www.sparkfun.com/products/11589
https://www.sparkfun.com/products/11373
https://www.sparkfun.com/products/12081
https://www.sparkfun.com/products/12640
https://www.sparkfun.com/products/11574
https://www.sparkfun.com/products/10264
https://www.sparkfun.com/products/12797
https://www.sparkfun.com/products/10039
https://www.sparkfun.com/products/12073
https://www.sparkfun.com/products/11888
https://www.sparkfun.com/products/10718
https://www.sparkfun.com/products/11868
https://www.sparkfun.com/products/10706
https://www.sparkfun.com/products/12577
https://www.sparkfun.com/products/13027
https://www.sparkfun.com/products/11058
https://www.sparkfun.com/products/13276
https://www.sparkfun.com/products/11740
https://www.sparkfun.com/products/10628
https://www.sparkfun.com/products/10846
https://www.sparkfun.com/products/11050
https://www.sparkfun.com/products/12856
https://www.sparkfun.com/products/11028
https://www.sparkfun.com/products/12086
https://www.sparkfun.com/products/13316
https://www.sparkfun.com/products/8483
https://www.sparkfun.com/products/11608
https://www.sparkfun.com/products/10419
https://www.sparkfun.com/products/11827
https://www.sparkfun.com/products/9718
https://www.sparkfun.com/products/10116
https://www.sparkfun.com/products/13160
https://www.sparkfun.com/products/12847
https://www.sparkfun.com/products/12866
https://www.sparkfun.com/products/11029
https://www.sparkfun.com/products/9269
https://www.sparkfun.com/products/11285
https://www.sparkfun.com/products/9544
https://www.sparkfun.com/products/549
https://www.sparkfun.com/products/11224
https://www.sparkfun.com/products/10167
https://www.sparkfun.com/products/11229
https://www.sparkfun.com/products/12584
https://www.sparkfun.com/products/116
https://www.sparkfun.com/products/11125
https://www.sparkfun.com/products/7914"
links = links_text.split(/\n/)
links.each do |link|
  data = JSON.parse open(link.strip + '.json').read
  next unless data['sparkfun_original']

  name = data['name']
  part = platform.parts.where(name: data['name']).first_or_initialize
  part.description = data['description']
  unless part.image
    part.build_image
    part.image.remote_file_url = data['images'].first['600']
  end
  part.store_link = link.strip
  part.workflow_state='approved'
  part.unit_price = data['price']
  part.save
end