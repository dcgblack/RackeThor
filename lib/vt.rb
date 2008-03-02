# $Id$

# Simple class to represent a datastructure that is made up of a 
# null terminted string followed by an arbitrary number of
# arbitrarily sized values, followed by a "rest" field.
class VT 
  # the value for this VT object
  attr_accessor :value
  # the array of types for this VT object
  attr_accessor :types
  # everything else
  attr_accessor :rest

  # Create a new VT which consists of a null terminated string
  # followed by some number of arbitrarily sized values, as 
  # specified by +args+
  def initialize(*args)
    @lengths = args
    @types = []
    @value = ""
  end 

  # Given +data+, return the value and an array
  # of the types as dictated by this instance
  def decode(data)
    null = data.index(0x00)
    value = data.unpack("a#{null}")[0]
    data = data.slice(null+1, data.length)
   
    n = 0
    types = []
    @lengths.each do |l|
      types[n] = data.unpack("#{punpack_string(l)}")[0]
      data = data.slice(l, data.length)
      n += 1
    end

    [value, types, data]
  end

  # Given +data+, set the +value+ and +types+ array
  # accordingly
  def decode!(data)
    @value, @types, @rest = self.decode(data)
  end
  
  # Return a string suitable for use elsewhere
  def encode
    s = "#{@value}\000"

    n = 0
    @lengths.each do |l|
      s << [@types[n]].pack("#{punpack_string(l)}")
      n += 1
    end
    s
  end

  def to_s
    encode
  end

  def to_str
    encode
  end

private
  # XXX: make this handle arbitrarily sized fields
  def punpack_string(size)
    s = ""
    case size
        when 1
          s << "C"
        when 2
          s << "n"
        when 4
          s << "N"
        else
          puts "Size #{s} not supported"
          exit
      end
    s
  end

end
# vim: set ts=2 et sw=2: