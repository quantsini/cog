#!/usr/bin/env ruby

require 'tempfile'
require 'open-uri'
require 'rexml/document'
include REXML

feed = ARGV[0] || 'nightly'

appcast = open("http://cogx.org/appcast/#{feed}.xml")

appcastdoc = Document.new(appcast)

#Get the latest revision from the appcast
appcast_revision = Regexp.new('\d+$').match(appcastdoc.elements['//channel/item/title'].text.to_s()).to_s().to_i() || 0

#Remove modified files that may cause conflicts.
%x[hg revert --all]

#Offset needed for SVN <=> HG conversion. We'll use 1000 because it's simple.
revision_offset = 1000

#Update to the latest revision
%x[hg pull -u]
latest_revision = %x[hg tip --style compact].match(/^[0-9]+/)[0].to_i() + revision_offset

if appcast_revision < latest_revision
  #Get the changelog
  changelog = %x[hg log --template '{desc}\n' -r #{latest_revision - revision_offset}:#{appcast_revision - revision_offset + 1}]

  description = ''
  ignore_next = false
  changelog.each_line do |line|
    if (ignore_next)
      ignore_next = false
      next
    end
    if Regexp.new('^-+$').match(line)
      ignore_next = true
      next
    elsif Regexp.new('^\s*$').match(line)
      next
    end
    description += line
  end
  
  #Remove the previous build directories
  %x[find . -type d -name build -print0 | xargs -0 rm -r ]

  #Update the version in the plist
  plist = open('Info.plist')
  plistdoc = Document.new(plist)
  plist.close()

  version_element = plistdoc.elements["//[. = 'CFBundleVersion']/following-sibling::string"];
  version_element.text = "r#{latest_revision}"

  newplist = open('Info.plist', 'w')
  plistdoc.write(newplist)
  newplist.close()

  #Build Cog!
  %x[xcodebuild -alltargets -configuration Release 2>&1].each_line do |line|
    if line.match(/\*\* BUILD FAILED \*\*/)
      exit
    end
  end

  filename = "Cog-r#{latest_revision}.tbz"

  #Zip the app!
  %x[rm -f build/Release/#{feed}.tar.bz2]
  %x[tar -C build/Release -cjf build/Release/#{feed}.tar.bz2 Cog.app]

  filesize = File.size("build/Release/#{feed}.tar.bz2")

  #Send the new build to the server
  %x[scp build/Release/#{feed}.tar.bz2 cogx@cogx.org:~/cogx.org/#{feed}_builds/#{filename}]

  #Add new entry to appcast
  new_item = Element.new('item')
  
  new_item.add_element('title')
  new_item.elements['title'].text = "Cog r#{latest_revision}"
  
  new_item.add_element('description')
  new_item.elements['description'].text = description

  new_item.add_element('pubDate')
  new_item.elements['pubDate'].text = Time.now().strftime("%a, %d %b %Y %H:%M:%S %Z") #RFC 822
  
  new_item.add_element('sparkle:minimumSystemVersion')
  new_item.elements['sparkle:minimumSystemVersion'].text =  '10.5.0'

  new_item.add_element('enclosure')
  new_item.elements['enclosure'].add_attribute('url', "http://cogx.org/#{feed}_builds/#{filename}")
  new_item.elements['enclosure'].add_attribute('length', filesize)
  new_item.elements['enclosure'].add_attribute('type', 'application/octet-stream')
  new_item.elements['enclosure'].add_attribute('sparkle:version', "r#{latest_revision}")
  
  appcastdoc.insert_before('//channel/item', new_item)
  
  #Limit number of entries to 5
  appcastdoc.delete_element('//channel/item[position()>5]')
  
  new_xml = Tempfile.new('appcast.xml')
  appcastdoc.write(new_xml)
  new_xml.close()
  appcast.close()
  
  #Send the updated appcast to the server
  %x[scp #{new_xml.path} cogx@cogx.org:~/cogx.org/appcast/#{feed}.xml]
  
end




