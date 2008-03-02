# $Id$

# Transmission Control Protocol: TCP
#
# RFC793 (http://www.faqs.org/rfcs/rfc793.html)
class TCP < RacketPart
  # Source port
  unsigned :src_port, 16
  # Destination port
  unsigned :dst_port, 16
  # Sequence number
  unsigned :seq, 32
  # Acknowledgement number
  unsigned :ack, 32
  # Data Offset
  unsigned :offset, 4
  # Reserved
  unsigned :reserved, 4
  # CWR
  unsigned :flag_cwr, 1
  # ECE
  unsigned :flag_ece, 1
  # URG
  unsigned :flag_urg, 1
  # ACK
  unsigned :flag_ack, 1
  # PSH
  unsigned :flag_psh, 1
  # RST
  unsigned :flag_rst, 1
  # SYN
  unsigned :flag_syn, 1
  # FIN
  unsigned :flag_fin, 1
  # Window size
  unsigned :window, 16
  # Checksum
  unsigned :csum, 16
  # Urgent pointer
  unsigned :urg, 16
  # Payload
  rest :payload

  # Add an TCP option to this TCP object.
  # All rejiggering will happen when the call to fix! 
  # happens automagically. 
  def add_option(number, value)
    t = TLV.new(1,1)
    t.type = number
    t.value = value
    t.length = value.length + 2
    @options << t.encode
  end

  # Check the checksum for this TCP packet 
  def checksum?(ip_src, ip_dst)
    self.csum == compute_checksum(ip_src, ip_dst)
  end

  # Compute and set the checksum for this TCP packet
  def checksum!(ip_src, ip_dst)
    self.csum = compute_checksum(ip_src, ip_dst)
  end

  # Fix this packet up for proper sending.  Sets the length
  # and checksum properly. 
  def fix!(ip_src, ip_dst, next_payload)
    newpayload = @options.join
    
    # pad to a multiple of 32 bits
    if ((self.class.bit_length/8 + newpayload.length) % 4 != 0) 
      # fill the beginning as needed with NOPs
      while ((self.class.bit_length/8 + newpayload.length) % 4 != 4)
        newpayload = "\x01#{newpayload}"
      end
    end

    self.payload = newpayload + self.payload + next_payload
    self.offset = self.class.bit_length/32 + newpayload.length/4
    self.checksum!(ip_src, ip_dst)
    self.payload = newpayload
  end

  def initialize(*args)
    @options = []
    super
    @autofix = false
  end

private
  # Compute the checksum for this TCP packet 
  def compute_checksum(ip_src, ip_dst)
    tmp = self.offset << 12
    tmp = tmp | (0x0f00 & (self.reserved << 8))
    tmp = tmp | (0x00ff & (
                   (self.flag_cwr << 7 & 0b10000000) +
                   (self.flag_ece << 6 & 0b01000000) +
                   (self.flag_urg << 5 & 0b00100000) +
                   (self.flag_ack << 4 & 0b00010000) + 
                   (self.flag_psh << 3 & 0b00001000) + 
                   (self.flag_rst << 2 & 0b00000100) + 
                   (self.flag_syn << 1 & 0b00000010) + 
                   (self.flag_fin << 0 & 0b00000001) 
                   ))

    pseudo = [L3::Misc.ipv42long(ip_src), L3::Misc.ipv42long(ip_dst), 6, self.class.bit_length/8 + self.payload.length ]
    header = [self.src_port, self.dst_port, self.seq, self.ack, tmp,
              self.window, 0, self.urg, self.payload]
    L3::Misc.checksum((pseudo << header).flatten.pack("NNnnnnNNnnnna*"))
  end
end
# vim: set ts=2 et sw=2: