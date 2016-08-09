require 'bloomer'
require 'bitset'
require 'base64'

describe BloomFilter do

  it 'should create' do
    bf = BloomFilter.new(1000, 0.001)
    expect(bf)
  end

  it 'should add' do
    bf = BloomFilter.new(1000, 0.001)
    #expect(bf).to be_not_nil

    key = [65, 66, 67]
    bf.add(key)
    expect(bf.test(key))
  end
  
  it 'should estimate correct parameters' do

    bf = BloomFilter.new(10000, 0.1)
    expect(bf.m).to  eq(47926) 
    expect(bf.k).to eq(4)

    bf = BloomFilter.new(10000, 0.001)
    expect(bf.m).to  eq(143776) 
    expect(bf.k).to eq(10)

    bf = BloomFilter.new(100, 0.1)
    expect(bf.m).to  eq(480) 
    expect(bf.k).to eq(4)

    bf = BloomFilter.new(100, 0.001)
    expect(bf.m).to  eq(1438) 
    expect(bf.k).to eq(10)

    bf = BloomFilter.new(5, 0.1)
    expect(bf.m).to  eq(24) 
    expect(bf.k).to eq(4)

    bf = BloomFilter.new(5, 0.001)
    expect(bf.m).to  eq(72) 
    expect(bf.k).to eq(10)
  end

  it 'should calculate fnv64Hash' do
    expect(BloomFilter.fnv64Hash(0, [65, 66, 67])).to eq(18027876433081418475)
    expect(BloomFilter.fnv64Hash(1, [65, 66, 67])).to eq(1576071963428640466)
    expect(BloomFilter.fnv64Hash(0, [68, 69, 70])).to eq(16156199779104085420)
    expect(BloomFilter.fnv64Hash(1, [68, 69, 70])).to eq(16897071604725882029)
    expect(BloomFilter.fnv64Hash(0, [100, 0, 3])).to eq(14688075775982111774)
    expect(BloomFilter.fnv64Hash(1, [100, 0, 3])).to eq(15312238840338909027)

    expect(BloomFilter.fnv64Hash(0, ['a', 'b', 'c'])).to eq(16654208175385433931)
    expect(BloomFilter.fnv64Hash(1, ['a', 'b', 'c'])).to eq(18882020881032690)
    expect(BloomFilter.fnv64Hash(0, ['x', 'y', 'z'])).to eq(13831867382062576672)
    expect(BloomFilter.fnv64Hash(1, ['x', 'y', 'z'])).to eq(14350673043201754233)
    expect(BloomFilter.fnv64Hash(0, ['l', 'i', 'j'])).to eq(1317986895110266884)
    expect(BloomFilter.fnv64Hash(1, ['l', 'i', 'j'])).to eq(1882708161834453005)
  end

  it 'should calculate base_hashes' do
    bh = BloomFilter.base_hashes([65, 66, 67])
    expect(bh).to match_array([18027876433081418475, 1576071963428640466, 825640983713069673, 2698130176783461432])

    bh = BloomFilter.base_hashes([68, 69, 70])
    expect(bh).to match_array([16156199779104085420, 16897071604725882029, 17527108260199447094, 4691975766770354319])
    
    bh = BloomFilter.base_hashes([100, 0, 3])
    expect(bh).to match_array([14688075775982111774, 15312238840338909027, 15936401904695706280, 3107151798476407005])
 
    bh = BloomFilter.base_hashes(['a', 'b', 'c'])
    expect(bh).to match_array([16654208175385433931, 18882020881032690, 17715195114875013513, 1324461919087476888])
    
    bh = BloomFilter.base_hashes(['x', 'y', 'z'])
    expect(bh).to match_array([13831867382062576672, 14350673043201754233, 14881023576434876594, 5505253729174906051])

    bh = BloomFilter.base_hashes(['l', 'i', 'j'])
    expect(bh).to match_array([1317986895110266884, 1882708161834453005, 2397806269764059974, 16645800209966207439])
  end

  it 'should calculate location' do
    bf = BloomFilter.new(100, 0.01)
    
    bh = BloomFilter.base_hashes([65, 66, 67])
    expect(bh).to match_array([18027876433081418475, 1576071963428640466, 825640983713069673, 2698130176783461432])
    expect(bf.location(bh, 0)).to eq(782)
    expect(bf.location(bh, 1)).to eq(507)
    expect(bf.location(bh, 2)).to eq(188)

    bh = BloomFilter.base_hashes([68, 69, 70])
    expect(bh).to match_array([16156199779104085420, 16897071604725882029, 17527108260199447094, 4691975766770354319])
    expect(bf.location(bh, 0)).to eq(958)
    expect(bf.location(bh, 1)).to eq(477)
    expect(bf.location(bh, 2)).to eq(938) 

    bh = BloomFilter.base_hashes([100, 0, 3])
    expect(bh).to match_array([14688075775982111774, 15312238840338909027, 15936401904695706280, 3107151798476407005])
    expect(bf.location(bh, 0)).to eq(880)
    expect(bf.location(bh, 1)).to eq(463)
    expect(bf.location(bh, 2)).to eq(329)

    bh = BloomFilter.base_hashes(['a', 'b', 'c'])
    expect(bh).to match_array([16654208175385433931, 18882020881032690, 17715195114875013513, 1324461919087476888])
    expect(bf.location(bh, 0)).to eq(215)
    expect(bf.location(bh, 1)).to eq(561)
    expect(bf.location(bh, 2)).to eq(405)

    bh = BloomFilter.base_hashes(['x', 'y', 'z'])
    expect(bh).to match_array([13831867382062576672, 14350673043201754233, 14881023576434876594, 5505253729174906051])
    expect(bf.location(bh, 0)).to eq(189)
    expect(bf.location(bh, 1)).to eq(450)
    expect(bf.location(bh, 2)).to eq(646)

    bh = BloomFilter.base_hashes(['l', 'i', 'j'])
    expect(bh).to match_array([1317986895110266884, 1882708161834453005, 2397806269764059974, 16645800209966207439])
    expect(bf.location(bh, 0)).to eq(104)
    expect(bf.location(bh, 1)).to eq(531)
    expect(bf.location(bh, 2)).to eq(896)
  end
  
  it 'should add to filter' do  
    bf = BloomFilter.new(100, 0.01)
  
    bf.add([65, 66, 67])
    expect(bf.test([65, 66, 67]))

    bf.add([68, 69, 70])
    expect(bf.test([68, 69, 70]))

    bf.add([100, 0, 3])
    expect(bf.test([100, 0, 3]))
  end

  it 'should add string to filter' do
    bf = BloomFilter.new(100, 0.01)

    bf.add("abc")
    expect(bf.test("abc"))

    bf.add("xyz")
    expect(bf.test("xyz"))

    bf.add("lij")
    expect(bf.test("lij"))

    bf.add("")
    expect(bf.test(""))
  end 

  it 'should encode_base64' do 
    bf = BloomFilter.new(100, 0.01)
    
    bf.add([65, 66, 67])
    expect(bf.encode_base64).to eq("AAAAAAAAA78AAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAADA=")

    bf.add([68, 69, 70])
    expect(bf.encode_base64).to eq("AAAAAAAAA78AAAAAAAAAAAAAAAgAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAABAAAAAgAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAIAAAAAAAAAAAAAAABAAAAAAAAAAAAAQAAEAAAAEDA=")

    bf.add([100, 0, 3])
    expect(bf.encode_base64).to eq("AAAAAAAAA78AAAAAAAAAAAAAAAgAAAAAEAACAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAgAAAAgABAAAAAgAAAAgAIgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAIAAAAAAAAAAAAAAIBAAAABAAAAAAAAQAAEAAAAEDA=")

    bf.add("abc")
    expect(bf.encode_base64).to  eq("AAAAAAAAA78AAAAAAAgAAAAAAAgAAAAAEAACAAAAAAAAAAAAAIAAAAAAAAAAAAEgAAAAAAAAAgAAAAgABCAAAAgAAAAgAIgAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAIAAAAAAAAAAAAAAIBAAQABAAAAAAAAQAAEABAAEDA=")

    bf.add("xyz")
    expect(bf.encode_base64).to eq("AAAAAAAAA7-AAAAAAAgAAAACAAgAAAAAMAACAAAAAAAAAAAAAIAAAAAAAAAAAAEgAAAAAAAAAgAAAAgABCAAAAgAAAAgAIgEAAIAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAIAAAAAAAAAAAAAAIBAQQABEAAAAAAAQAAEABAAEDA=")

    bf.add("lij")
    expect(bf.encode_base64).to eq("AAAAAAAAA7-AAAAAAAgAAAACAQgAAAAAMAACAAAAAAAAAAAAAIAAAAAAAAAAAAEgAAAAAAAAAgAAAAgABCAAAAgAAAAgAIgEAAIAAAAIAAAAAAAAAAAACAAAIAAAAEBAQAIAAAAAAAAAAAAAAIDAQQABEAAAAAAAQAAEABAAEDE=")


    bf = BloomFilter.new(5, 0.01)
    
    bf.add([65, 66, 67])
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAIAACAAsAA==")

    bf.add([68, 69, 70])
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAIRAGRAsAA==")

    bf.add([100, 0, 3])
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAIVAGRBsAQ==")

    bf.add("abc")
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAIVAGRBsAQ==")

    bf.add("xyz")
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAIVAGRH8BQ==")

    bf.add("lij")
    expect(bf.encode_base64).to eq("AAAAAAAAADAAAMVQGRH8BQ==")
  end

end
