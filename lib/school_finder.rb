require "school_finder/version"
require 'net/http'
require 'json'
# require 'uri'

# pseudo code
# while loop searching through each page in edubase
#   while condition: can set to items is empty then break
#     or can do if item_per_page <10 then break

# inside the while loop search for matching criteria (unique reference number of school or postcode), put it into an array then break

# send the information to zoopla and return house prices and other information in the area

module SchoolFinder
  def self.create_hash
    schools_hash = []
    page_number = 1
    page_number_string = page_number.to_s
    school_page = "http://education.data.gov.uk/doc/school.json?_pageSize=50&_page=" + page_number_string
    resp = Net::HTTP.get_response(URI.parse(school_page))
    buffer = resp.body
    # puts buffer.class
    page_hash = JSON.parse(buffer)


    puts page_hash['result']['items']
    puts page_hash['result']['items']['uniqueReferenceNumber']
    puts page_hash['result']['items']['label']
    puts page_hash['result']['items']['_about']
    # http://education.data.gov.uk/id/school/100866
  end

end
