# $Id: eightotwodotthree.rb 14 2008-03-02 05:42:30Z warchild $
#
# Copyright (c) 2008, Jon Hart 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY Jon Hart ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Jon Hart BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
module Racket
module L2
# 
# ==== +802.3 Ethernet+
# Should always be followed by an LLC(Logical Link Control) header.
# 
# 	A data packet on an Ethernet link is called an Ethernet packet, which 
# 	transports an Ethernet frame as payload.
# 	
# 	The 802.3 packet header looks usualy looks like:
# 	| Preamble | Dest Addr | Src Addr | Type | Payload  | FCS |
# 	|    8B    |     6B    |    6B    |  2B  | 46-1500B | 4B  |
# 
# 	==== Ether Type - Type
# 	Values of 1500 (0x05DC) and below for this field indicate that the field 
# 	is used +as the size of the payload of the Ethernet Frame+ while values of 
# 	1536 and above indicate that the field is used to represent EtherType.
# 	The interpretation of values 1501–1535, inclusive, is undefined.
# 	
# 	Thus the 802.3 would be used instead of Ethernet II only when the type is
# 	lower than 1501.
# 
class EightOTwoDotThree < RacketPart
  
  hex_octets :dst_mac, 48         # Destination MAC address
  hex_octets :src_mac, 48         # Source MAC address
  unsigned :payload_length, 16    # Length of the payload 
  rest :payload                   # Payload

  # Fix this layer up prior to sending.  For 802.3, just adjusts +length+
  def fix!
    self.payload_length = self.payload.length
  end
end
end
end
# vim: set ts=2 et sw=2:
