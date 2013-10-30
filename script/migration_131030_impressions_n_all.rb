{59=>3659,72=>130,31=>116,27=>98,32=>97,39=>84,61=>79,36=>60,60=>54,25=>52,57=>50,43=>46,49=>38,68=>35,44=>34,50=>34,47=>33,51=>32,40=>31,53=>31,54=>31,35=>29,38=>29,33=>28,41=>25,58=>23,62=>23,63=>23,56=>22,65=>14,29=>12,48=>11,64=>11,46=>10,52=>10,55=>10,37=>6,45=>6,42=>5,67=>5,66=>4,30=>3,34=>3,71=>3,69=>2,70=>2,74=>1}.each do |project_id,max|
  (1..max).each do |i|
    Impression.create({
          :controller_name => 'projects',
          :action_name => 'show',
          :user_id => nil,
          :request_hash => Digest::SHA2.hexdigest(Time.now.to_f.to_s+rand(10000).to_s),
          :session_hash => i,
          :ip_address => '127.0.0.1',
          :referrer => nil,
          :impressionable_type => 'Project',
          :impressionable_id=> project_id
      })
  end
end

User.where(invited_by_type: 'Account').update_all(invited_by_type: 'User')