require "school_finder/version"
require 'net/http'
require 'json'

# pseudo code
# while loop searching through each page in edubase
#   while condition: can set to items is empty then break
#     or can do if item_per_page <10 then break - no!
#       because items_per_page will still be 10 even if there are only 8

# inside the while loop search for matching criteria (unique reference number of school or postcode), put it into an array then break

# send the information to zoopla and return house prices and other information in the area


module SchoolFinder

  # def self.find_info_by_postcode(zip, graph_size="large")
  #    find_schools_by_postcode(zip)
  #    zoopla_index(zip)
  #    zoopla_graph(zip, graph_size)
  # end

  def self.find_schools_by_postcode(zip)

    page_number = 1
    schools_array = []
    page_items_array = ["initial_value"]

    # until page_items_array.length == 0 do
      schools_page = "http://education.data.gov.uk/doc/school.json?_pageSize=50&_page=" + page_number.to_s
        # puts school_page
      resp = Net::HTTP.get_response(URI.parse(schools_page))
      buffer = resp.body
        # puts buffer.class returns string
      page_hash = JSON.parse(buffer)
        # puts page_hash.class returns hash
      page_items_array = page_hash['result']['items']

      get_address(page_items_array)

        # puts page_items_array.class returns array
        # containing a hash for each school
      schools_array += page_items_array
        # puts page_items_array
        # puts page_hash['result']['items']
        # puts page_hash['result']['items']['uniqueReferenceNumber']
        # puts page_hash['result']['items']['label']
        # puts page_hash['result']['items']['_about']
        # http://education.data.gov.uk/doc/school/100866
      puts "searching page #{page_number}"
      page_number += 1
    # end

    # puts (schools_array[0]).class #returns hash
    # puts schools_array[0]

    # need to loop through each hash and
    # select names of schools from each hash
    # that equal the postcode entered in the search
    get_search_results(zip, schools_array)
    # return search_result
  end

  def self.get_address(array)
    array.each do |x|
        # gets the url for the school info
      a = x['uniqueReferenceNumber']
        # puts a returns the url for the school
      school_page = 'http://education.data.gov.uk/doc/school/' + a.to_s + '.json'
        # puts school_page returns the json for the school
      school_resp = Net::HTTP.get_response(URI.parse(school_page))
      school_buffer = school_resp.body
        # puts school_buffer
      school_hash = JSON.parse(school_buffer)
        # puts school_hash.class returns hash for each school url that is parsed

      full_postcode = school_hash['result']['primaryTopic']['address']['postcode']
      short_postcode = full_postcode.split.first
      address1 = school_hash['result']['primaryTopic']['address']['address1']
      address2 = school_hash['result']['primaryTopic']['address']['address2']
      town = school_hash['result']['primaryTopic']['address']['town']

      x['address1'] = address1
      x['address2'] = address2
      x['town'] = town
      x['full_postcode'] = full_postcode
      x['short_postcode'] = short_postcode
        # puts x
    end
  end

  # searchs through the schools_array built above
  # returns an array search_result of schools in the given postcode

  def self.get_search_results(zip, schools_array)

    n = schools_array.length - 1
    search_result = []

    for i in 0..n
      if schools_array[i]["short_postcode"] == zip
        schools_array[i]['label'].nil? ? name = "" : name = schools_array[i]['label']
        schools_array[i]['address1'].nil? ? address1 = "" : address1 = schools_array[i]['address1']
        schools_array[i]['address2'].nil? ? address2 = "" : address2 = schools_array[i]['address2']
        schools_array[i]['town'].nil? ? town = "" : town = schools_array[i]['town']
        schools_array[i]['full_postcode'].nil? ? full_postcode = "" : full_postcode = schools_array[i]['full_postcode']
        result = name + ", " + address1 + ", " + address2 + ", " + town + ", " + full_postcode
        search_result << result
      end
    end
    search_result
  end

  def self.zoopla_index(zip)
    zed_index_url = 'http://api.zoopla.co.uk/api/v1/zed_index.json?area=' + zip + '&output_type=outcode&api_key=' + ENV['ZOOPLA_ID'].to_s
    # puts zed_index_url...
    # need to edit so that env variable is not published in url,
    #   not important for this gem since:
    #   local to the registered app and accessing public info?
    zed_index_resp = Net::HTTP.get_response(URI.parse(zed_index_url))
    # puts zed_index_resp
    zed_index_buffer = zed_index_resp.body
    zed_index_hash = JSON.parse(zed_index_buffer)
    # puts zed_index_hash
    zed_index = zed_index_hash['zed_index']
    # need to fix currency conversion - this is a ruby helper?
    zed_index = "£" + zed_index
    # zed_index = zed_index.to_money
    # zed_index = number_to_currency(zed_index, :unit => "&pound;", :separator => ",")
    zed_index
    # puts zed_index.class returns string
  end

  def self.zoopla_graph(zip, graph_size="large")
    area_graph_url = 'http://api.zoopla.co.uk/api/v1/area_value_graphs.js?area=' + zip + '&output_type=outcode&api_key=' + ENV['ZOOPLA_ID'].to_s
    # puts area_graph_url.class returns string
    # as above key in url?
    area_graph_resp = Net::HTTP.get_response(URI.parse(area_graph_url))
    area_graph_buffer = area_graph_resp.body
    area_graph_hash = JSON.parse(area_graph_buffer)
      # puts area_graph_hash
    average_values_graph = resize_graph(graph_size, area_graph_hash['average_values_graph_url'])
    # puts average_values_graph.class returns string
    value_ranges_graph = resize_graph(graph_size, area_graph_hash["value_ranges_graph_url"])
    value_trend_graph = resize_graph(graph_size, area_graph_hash["value_trend_graph_url"])
    home_values_graph = resize_graph(graph_size, area_graph_hash["home_values_graph_url"])
    more_info_url = area_graph_hash["area_values_url"]

    graph_links = [average_values_graph, value_ranges_graph, value_trend_graph, home_values_graph, more_info_url]
    # graph_links = { :average_values_graph => average_values_graph,
    #                 :value_ranges_graph => value_ranges_graph,
    #                 :value_trend_graph => value_trend_graph,
    #                 :home_values_graph => home_values_graph,
    #                 :more_info_url => more_info_url
    #               }
    graph_links
  end

  def self.resize_graph(graph_size, graph_url)
    case graph_size
      when "small"
        graph_url.sub(/width=\d*\&/, "width=200").sub(/height=\d*/, "height=106")
      when "medium"
        graph_url.sub(/width=\d*\&/, "width=400").sub(/height=\d*/, "height=212")
      when "large"
        graph_url.sub(/width=\d*\&/, "width=600").sub(/height=\d*/, "height=318")
    end
  end

end
