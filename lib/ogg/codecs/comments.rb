
module Ogg
  
  #See http://www.xiph.org/vorbis/doc/v-comment.html
  #Methods to pack/unpack vorbis comment packets
  #intended to be included into Codec classes
  module VorbisComments
    
    #unpack a packet, skipping the preamble
    #returns a 2 element array being a Hash of tag/value pairs and the vendor string
    def unpack_comments(packet,preamble="")
      
      pio = StringIO.new(packet)
      pio.read(preamble.length)
      
      vendor_length = pio.read(4).unpack("V").first
      vendor = pio.read(vendor_length)
      
      tag = { }
      tag_size = pio.read(4).unpack("V")[0]
      
      tag_size.times do |i|
        size = pio.read(4).unpack("V")[0]
        comment = pio.read(size)
        key, val = comment.split(/=/, 2)
        #Oh noes - the old OggInfo downcases the tag keys!
        #we can't do that if we are going to write them back
        #Hmm, come to think of it neither could the original OggInfo...
        tag[key] = val
      end
      
      #framing bit = pio.read(1).unpack("C")[0] 
      
      [ tag, vendor ]
    end
    
    #Pack tag Hash and vendor string into an ogg packet.
    def pack_comments(tag,vendor,preamble="")
      packet_data = StringIO.new()
      packet_data << preamble
      
      packet_data << [ vendor.length ].pack("V")
      packet_data << vendor
      
      packet_data << [tag.size].pack("V")
      tag.each do |k,v|
        tag_data = "#{ k }=#{ v }"
        packet_data << [ tag_data.length ].pack("V")
        packet_data << tag_data
      end
      
      packet_data << "\001"
      result = packet_data.string
      return result
    end
  end
end