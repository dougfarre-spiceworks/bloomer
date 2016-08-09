SIXTY_FOUR_BIT_MASK = (2**64) - 1
THIRTY_TWO_BIT_MASK = (2**32) - 1

require 'bitset'
require 'base64'
require 'json'

class BloomFilter
  attr_accessor :m, :k, :b

  # Creates a new bloom filter with m bits and k hashing functions determined by estimate parameters
  def initialize(n,p)
    estimate_parameters(n, p)
    self.b = Bitset.new(self.m)
  end

  # Returns m bits and k hashing functions necessary for bloom filter given n bits of data and desired false positive rate
  def estimate_parameters(n, fp)
   self.m = ((-1 * Float(n) * Math.log(fp) / (Math.log(2) ** 2)).ceil).to_i
   self.k = ((Math.log(2) * Float(m) / Float(n)).ceil).to_i
  end

  # Returns the four hash values of data that are used to create k hashes
  def self.base_hashes(data)
    (0...4).collect{|i| BloomFilter.fnv64Hash(i, data)}
  end

  # Returns the data after it has been converted to big endian and base64 encoded
  def encode_base64
    data = [m].pack("Q>")
    padding = ["0"] * (64 - (m % 64))
    b_with_padding = b.to_s.split("") + padding
    
    b_as_bytes = []
    b_with_padding.each_slice(64) do |word|
      word.reverse.each_slice(8) do |byte|
        b_as_bytes << byte.join.to_i(2)
      end
    end

    data << b_as_bytes.pack("c*")

    Base64.urlsafe_encode64(data)
  end

  # Returns the filter in JSON format
  def to_json
    {
      m: m,
      k: k,
      b: self.encode_base64
    }.to_json
  end

  # Returns the ith hashed location using the four base hash values
  def location(h, i)
    i &= SIXTY_FOUR_BIT_MASK
    location = ((h[i%2] & SIXTY_FOUR_BIT_MASK) + (i*h[2+(((i+(i%2))%4)/2)] & SIXTY_FOUR_BIT_MASK)) & SIXTY_FOUR_BIT_MASK
    location  %= self.m
  end

  # Adds data to the Bloom Filter 
  def add(data)
    if data.is_a? Fixnum
      data = [data]
    elsif data.is_a? String
      data = data.split("")
    end
    h = BloomFilter.base_hashes(data)
    (0...k).each do |i|
      loc = location(h,i)
      self.b.set(loc)
    end
    true
  end

  # Tests for the presence of data in the Bloom Filter
  def test(data)
    if data.is_a? Fixnum
      data = [data]
    elsif data.is_a? String
      data = data.split("")
    end
    h = BloomFilter.base_hashes(data)
    (0...k).each do |i|
      loc = location(h,i)
      return false unless self.b.set?(loc)
    end
    true
  end

  # Hashing function
  def self.fnv64Hash(index, data)
    # input checking
    index &= SIXTY_FOUR_BIT_MASK
    hash = index + 14695981039346656037
    data.each do |i|
      next if i.nil?
      i = i.ord
      i &= SIXTY_FOUR_BIT_MASK
      hash ^= i
      hash *= 1099511628211
      hash &= SIXTY_FOUR_BIT_MASK
    end
    hash
  end
 
private :add_string
end
