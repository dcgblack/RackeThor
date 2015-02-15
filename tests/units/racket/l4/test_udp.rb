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
end
