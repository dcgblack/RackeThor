$:.unshift File.join(File.dirname(__FILE__), "../../../..", "lib")

gem 'minitest'
require "minitest/autorun"
gem 'mocha'
require 'mocha/mini_test'

require "racket"

#
# Units test for UDP class
#
describe "UDP" do
	before do
	  @udp = Racket::L4::UDP.new
	  
	  @src_ip = "192.168.1.10"
	  @dst_ip = "192.168.1.15"
	  @checksum_value = 12345
	  @wrong_checksum = 01234
	end

  describe "when initialized and asked about autofix" do
    it "must respond negatively " do
      @udp.autofix.must_equal false
    end
  end

	describe "when asked about checksum with checksum equal to zero" do
	  it "must respond positively" do
	    @udp.expects(:checksum).returns(0)
      
      @udp.checksum?(@src_ip, @dst_ip).must_equal true
	  end
	end
	
	describe "when asked about checksum with checksum different to zero" do
	  it "must respond positively if checksum equal to compute_checksum" do
      @udp.expects(:checksum).returns(@checksum_value).twice
      @udp.expects(:compute_checksum).with(@src_ip, @dst_ip).returns(@checksum_value)
      
      @udp.checksum?(@src_ip, @dst_ip).must_equal true
	  end
	end

	describe "when asked about checksum with checksum different to zero" do
	  it "must respond negatively if checksum different to compute_checksum" do
      @udp.expects(:checksum).returns(@wrong_checksum)
      @udp.expects(:checksum).returns(@wrong_checksum)
      @udp.expects(:compute_checksum).with(@src_ip, @dst_ip).returns(@checksum_value)
      
      @udp.checksum?(@src_ip, @dst_ip).must_equal false
	  end
	end
  
  describe "when asked to calculate the checksum" do
    it "must calculate and set the value" do
      @udp.expects(:compute_checksum).with(@src_ip, @dst_ip).returns(@checksum_value)
      @udp.checksum!(@src_ip, @dst_ip)
      
      @udp.checksum.must_equal @checksum_value
    end
  end

  describe "when asked to fix the packet" do
    it "must set the length and checksum properly" do
      bit_length = 24
      pay_length = 1
      result = 4
      
      class_mock = mock('class mock')
      @udp.expects(:class).returns(class_mock)
      class_mock.expects(:bit_length).returns(bit_length)
      
      payload_mock = mock('payload mock')
      @udp.expects(:payload).returns(payload_mock)
      payload_mock.expects(:length).returns(pay_length)
            
      @udp.expects(:checksum!).with(@src_ip, @dst_ip).returns(@checksum_value)      
      
      @udp.fix!(@src_ip, @dst_ip)
      
      @udp.len.must_equal result
    end
  end
  
  describe "when asked to compute the checksum" do
    it "must calculate the value" do
      bit_length = 24
      pay_length = 1
      result = 4
      src_long = 3232235786
      dst_long = 3232235791
      src_port = 1
      dst_port = 2
      payload_str = ""
      
      Racket::L3::Misc.expects(:ipv42long).with(@src_ip).returns(src_long)
      Racket::L3::Misc.expects(:ipv42long).with(@dst_ip).returns(dst_long)
      
      payload_mock = mock('payload mock')
      seq = sequence('payload')
      @udp.expects(:payload).returns(payload_mock).in_sequence(seq)
      @udp.expects(:payload).returns(payload_mock).in_sequence(seq)
      @udp.expects(:payload).returns(payload_str).in_sequence(seq)
      payload_mock.expects(:length).returns(pay_length).twice
      
      class_mock = mock('class mock')
      @udp.expects(:class).returns(class_mock).twice
      class_mock.expects(:bit_length).returns(bit_length).twice
      pseudo = [src_long, dst_long, 17, result]
      
      @udp.expects(:src_port).returns(src_port)
      @udp.expects(:dst_port).returns(dst_port)
      header = [src_port, dst_port, result, 0, ""]
      
      arg = (pseudo << header).flatten.pack("NNnnnnnna*")
      Racket::L3::Misc.expects(:checksum).with(arg).returns(@checksum_value)

      checksum_result = @udp.__send__(:compute_checksum, @src_ip, @dst_ip)
      
      checksum_result.must_equal @checksum_value
    end
  end  
end
