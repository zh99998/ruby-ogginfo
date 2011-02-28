module Ogg
  class Vorbis
    include VorbisComments
    # return true/false based on whether the header packet belongs to us
    def match?(header_packet)
      /^\001vorbis.*/ =~ header_packet
    end
    
    #consume header and tag pages, return array of two hashes, info and tags 
    def decode_headers(reader)
      init_pkt, tag_pkt, setup_pkt = reader.packets(3)
      info = extract_info(init_pkt)
      info[:tag], info[:tag_vendor] = unpack_comments(tag_pkt, "\003vorbis")
      info
    end
    
    #consume pages with old tags/setup packets and rewrite newtags,setup packets
    def replace_tags(reader,writer,new_tags,vendor)
      tag_pkt, setup_pkt = reader.packets(2)
      writer.write_packets(0, pack_comments(new_tags, vendor, "\003vorbis"), setup_pkt)
    end
    
    def extract_info(packet)
      vorbis_string,
      vorbis_version,
      channels,
      samplerate,
      upper_bitrate,
      nominal_bitrate,
      lower_bitrate = packet.unpack("a7VCV4")
      
      if nominal_bitrate == 0
        if (upper_bitrate == 2**32 - 1) || (lower_bitrate == 2**32 - 1)
          nominal_bitrate = 0
        else
          nominal_bitrate = ( upper_bitrate + lower_bitrate) / 2
        end
      end
      
      return { :channels => channels, :samplerate => samplerate, :nominal_bitrate => nominal_bitrate }
    end
  end
end
