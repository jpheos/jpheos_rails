require 'open-uri'
require 'nokogiri'

class GetContactsFromGoogle
  attr_reader :contacts

  def self.call(token)
    instance = self.new(token)
    instance.call
    instance.contacts
  end

  def initialize(token)
    @token = token
    @contacts = []
  end

  def call
    page = Nokogiri::XML(open("https://www.google.com/m8/feeds/contacts/default/full?max-results=1000", "GData-Version" => "3.0", "Authorization" => "Bearer #{@token}"))
#     debug= '<?xml version="1.0" encoding="UTF-8"?>
# <entry gd:etag="&quot;QHk7ejVSLyt7I2A9XBdQEUUJRgE.&quot;" xmlns="http://www.w3.org/2005/Atom" xmlns:batch="http://schemas.google.com/gdata/batch" xmlns:gContact="http://schemas.google.com/contact/2008" xmlns:gd="http://schemas.google.com/g/2005">
#     <id>http://www.google.com/m8/feeds/contacts/jooo.blanchard%40gmail.com/base/7299d4c48dcef482</id>
#     <updated>2017-12-13T16:39:11.702Z</updated>
#     <app:edited xmlns:app="http://www.w3.org/2007/app">2017-12-13T16:39:11.702Z</app:edited>
#     <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/contact/2008#contact"/>
#     <title>Gaëlle DULIÈGE</title>
#     <content>Interphone: 4738</content>
#     <link rel="self" type="application/atom+xml" href="https://www.google.com/m8/feeds/contacts/jooo.blanchard%40gmail.com/base/7299d4c48dcef482"/>
#     <link rel="edit" type="application/atom+xml" href="https://www.google.com/m8/feeds/contacts/jooo.blanchard%40gmail.com/base/7299d4c48dcef482"/>
#     <gd:name>
#         <gd:fullName>Gaëlle DULIÈGE</gd:fullName>
#         <gd:givenName>Gaëlle</gd:givenName>
#         <gd:familyName>DULIÈGE</gd:familyName>
#     </gd:name>
#     <gContact:birthday when="1990-12-07"/>
#     <gd:email rel="http://schemas.google.com/g/2005#home" address="gaelleduliege@gmail.com" primary="true"/>
#     <gd:phoneNumber rel="http://schemas.google.com/g/2005#mobile" primary="true" uri="tel:+33-6-45-70-42-95">0645704295</gd:phoneNumber>
#     <gd:phoneNumber rel="http://schemas.google.com/g/2005#home" uri="tel:+33-4-26-01-32-97">09 87 39 35 71</gd:phoneNumber>
#     <gd:structuredPostalAddress label="bourdeau">
#         <gd:formattedAddress>le Biollet
# 73370 BOURDEAU</gd:formattedAddress>
#         <gd:street>le Biollet</gd:street>
#         <gd:city>BOURDEAU</gd:city>
#         <gd:postcode>73370</gd:postcode>
#     </gd:structuredPostalAddress>
#     <gContact:website href="http://www.google.com/profiles/104991693249249107305" rel="profile"/>
# </entry>'
    # page = Nokogiri::XML(debug)
    page.search("entry").each do |node_contact|
      # href_photo = e.search('link[rel="http://schemas.google.com/contacts/2008/rel#photo"]').map{|node| node["href"]}.first
      birthday = extract_birthday(node_contact)
      next if birthday.nil?

      contact = {
        name: extract_fullname(node_contact),
        birthday: Date.strptime(birthday, "%Y-%m-%d"),
        phone: extract_phone(node_contact),
        email: extract_email(node_contact),
        google_id: extract_id(node_contact)
      }

      contact[:photo] = get_photo(contact[:google_id])

      @contacts << contact
    end
  end

  private

  def extract_birthday(node_contact)
    node_contact.xpath("gContact:birthday").map{|node| node["when"]}.first
  end

  def extract_fullname(node_contact)
    node_contact.xpath("gd:name").xpath("gd:fullName").text
  end

  def extract_phone(node_contact)
    nodes = node_contact.xpath("gd:phoneNumber")
    return if nodes.empty?
    node = nodes.find{|n| n[:primary]}
    (node || nodes.first).text
  end

  def extract_email(node_contact)
    node = node_contact.xpath("gd:email").find{|n| n[:primary]}
    return unless node
    node['address']
  end

  def extract_id(node_contact)
    node_contact.css("id").text[/\/(\w+)\z/,1]
  end

  def get_photo(google_id)
    url = "https://www.google.com/m8/feeds/photos/media/default/#{google_id}"
    headers = {"GData-Version" => "3.0", "Authorization" => "Bearer #{@token}"}
    open(url, headers).read
  end
end
