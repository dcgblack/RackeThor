gem "minitest"
require "minitest/autorun"

require_relative "../../../../lib/racket/misc/lv.rb"

describe "#{Racket::Misc::LV} without arguments" do
  before do
    @lv = Racket::Misc::LV.new
  end

  describe "when I ask to decode the data" do
    it "should return the same value" do
      @lv.decode("data")[2].must_equal "data"

    end
  end

  describe "when I ask to decode! the data" do
    it "should return the same value" do
      @lv.decode!("data")[2].must_equal "data"

    end
  end

  describe "when I ask to encode" do
    it "must be empty" do
      @lv.encode.must_be_empty

    end
  end

  describe "when I ask to convert to string" do
    it "must be empty" do
      @lv.to_s.must_be_empty

    end
  end

  describe "when I ask to convert to string" do
    it "must be empty" do
      @lv.to_str.must_be_empty

    end
  end
end