require 'json'
require 'net/http'
OCTOPART_API_KEY = Rails.env.production? ? '67db2f71' : '2d933f78'

class Octopart
  def self.search part_name#parts

    # return false if parts.empty?

    url = "http://octopart.com/api/v3/parts/search"

    # map queries
#     queries = parts.map.with_index do |part, i|
#       {
#         reference: i,
# #        q: [part.mpn, part.description].join(' '),
#         mpn: part.mpn,
#       }
    # end

    # url += "?queries=" + URI.encode(JSON.generate(queries))
    params = {
      q: part_name,
      # limit: 1,
      apikey: OCTOPART_API_KEY,
      "filter[fields][offers.seller.name]" => 'Digi-Key',
      'sortby' => 'avg_price',
    }
    url += '?' + params.to_param

    resp = Net::HTTP.get_response(URI.parse(url))
    server_response = JSON.parse(resp.body)

    # return server_response

    lowest_price = 9999999.99
    cheapest_offer = nil

    server_response['results'].each do |result|
      catch :next_result do
        item = result['item']

        item['offers'].each do |offer|
          if offer['seller']['name'] == 'Digi-Key'
            throw :next_result unless offer['moq'] == 1

            price = offer['prices']['USD'].first.last.to_f
            if price < lowest_price
              lowest_price = price
              cheapest_offer = item
            end

            throw :next_result
          end
        end if item.try(:[], 'offers')
      end
    end if server_response['results']

    # return cheapest_offer
    # puts cheapest_offer.inspect

    # result = server_response['results'].first['item']
    return {
      octopart_url: cheapest_offer['octopart_url'],
      mpn: cheapest_offer['mpn'],
      vendor_name: 'Digi-Key',
      price: lowest_price,
    } if cheapest_offer



#     server_response['results'].each do |result|
#       next unless i = result['reference']
#       part = parts[i]
#       item = result['items'].first  # use first result

#       # find cheapest
#       lowest_price = 999999999
#       cheapest_offer = nil
#       item['offers'].each do |offer|
#         prices = offer['prices']['USD']
#         if prices and prices.first.last.to_f < lowest_price
#           lowest_price = prices.first.last.to_f
#           cheapest_offer = offer
#         end
#       end if item

#       # save results to part
#       if cheapest_offer
# #        part.mpn = item['mpn'] unless part.mpn.present?
#         part.unit_price = lowest_price
#         part.vendor_link = item['octopart_url']
#         part.compute_total_cost
#       else
#         part.unit_price = nil
#         part.total_cost = nil
#         part.vendor_link = nil
#       end
#       part.save
#     end if 'results'.in? server_response
  end
end