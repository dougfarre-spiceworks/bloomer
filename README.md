# Bloom Filter 

A bloom filter is a space-efficient, probabilistic data structure that represents large sets (https://en.wikipedia.org/wiki/Bloom\_filter)

This particular implementation of a bloom filter produces a filter that is compatible with this Go implementation (https://github.com/willf/bloom)

# Installation
		gem install bloom_filter
# Example Usage

		require bloom_filter
                
    # Make a new bloom filter with data of size 500 bits and false positive rate of 0.1 %
        bf = BloomFilter.new(500, 0.1)
              
    # Add data to the bloom filter
  	    bf.add(800)
   		bf.add([1, 2, 3])
		bf.add("test")
 
    # Test the presence of the data
		bf.test(800) => true
		bf.test("abc") => false

    # Print out the bloom filter in JSON format
		bf.to_json

 


