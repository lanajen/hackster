require 'json'
require 'net/http'
OCTOPART_API_KEY = '8335b79b'

class Octopart
  def self.match parts

    return false if parts.empty?

    url = "http://octopart.com/api/v3/parts/match"

    # map queries
    queries = parts.map.with_index do |part, i|
      {
        reference: i,
#        q: [part.mpn, part.description].join(' '),
        mpn: part.mpn,
      }
    end

    url += "?queries=" + URI.encode(JSON.generate(queries))
    url += "&apikey=#{OCTOPART_API_KEY}"

    resp = Net::HTTP.get_response(URI.parse(url))
    server_response = JSON.parse(resp.body)

    server_response['results'].each do |result|
      next unless i = result['reference']
      part = parts[i]
      item = result['items'].first  # use first result

      # find cheapest
      lowest_price = 999999999
      cheapest_offer = nil
      item['offers'].each do |offer|
        prices = offer['prices']['USD']
        if prices and prices.first.last.to_f < lowest_price
          lowest_price = prices.first.last.to_f
          cheapest_offer = offer
        end
      end if item

      # save results to part
      if cheapest_offer
#        part.mpn = item['mpn'] unless part.mpn.present?
        part.unit_price = lowest_price
        part.vendor_link = item['octopart_url']
        part.compute_total_cost
      else
        part.unit_price = nil
        part.total_cost = nil
        part.vendor_link = nil
      end
      part.save
    end
  end
end