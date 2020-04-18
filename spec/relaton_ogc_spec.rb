require "jing"

RSpec.describe RelatonOgc do
  it "has a version number" do
    expect(RelatonOgc::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonOgc.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "fetch hit" do
    VCR.use_cassette "data" do
      hit_collection = RelatonOgc::OgcBibliography.search("OGC 19-025r1")
      expect(hit_collection.fetched).to be_falsy
      expect(hit_collection.fetch).to be_instance_of RelatonOgc::HitCollection
      expect(hit_collection.fetched).to be_truthy
      expect(hit_collection.first).to be_instance_of RelatonOgc::Hit
    end
  end

  context "return xml of hit" do
    it "with bibdata root elemen" do
      VCR.use_cassette "data" do
        hits = RelatonOgc::OgcBibliography.search("OGC 19-025r1")
        path = "spec/fixtures/hit.xml"
        xml = hits.first.to_xml bibdata: true
        File.write path, xml, encoding: "UTF-8" unless File.exist? path
        expect(xml).to be_equivalent_to File.open(path, "r:UTF-8", &:read).
          gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        schema = Jing.new "spec/fixtures/isobib.rng"
        errors = schema.validate path
        expect(errors).to eq []
      end
    end
  end

  context "get code" do
    it "with edition" do
      VCR.use_cassette "data" do
        result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", nil, {}
        expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
      end
    end

    it "with year" do
      VCR.use_cassette "data" do
        result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", "2019", {}
        expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
      end
    end

    it "with wrog year" do
      VCR.use_cassette "data" do
        expect do
          result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", "2018", {}
          expect(result).to be_nil
        end.to output(%r{WARNING: no match found online for OGC 19-025r1 year 2018}).to_stderr
      end
    end

    it "ignore CC types" do
      VCR.use_cassette "data" do
        path = "spec/fixtures/12_128r14.xml"
        result = RelatonOgc::OgcBibliography.get "12-128r14", nil, {}
        xml = result.to_xml bibdata: true
        File.write path, xml, encoding: "UTF-8" unless File.exist? path
        expect(xml).to be_equivalent_to File.read(path, encoding: "UTF-8").
          sub /(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s
        schema = Jing.new "spec/fixtures/isobib.rng"
        errors = schema.validate path
        expect(errors).to eq []
      end
    end

    it "returns last date" do
      VCR.use_cassette "data" do
        result = RelatonOgc::OgcBibliography.get "16-079", nil, {}
        expect(result.doctype).to eq "standard"
        expect(result.docsubtype).to eq "implementation"
      end
    end

    it "get OGC 15-043r3" do
      VCR.use_cassette "data" do
        result = RelatonOgc::OgcBibliography.get "OGC 15-043r3"
        expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
      end
    end

    it "get document with unknown type" do
      VCR.use_cassette "ogc_09_048" do
        result = RelatonOgc::OgcBibliography.get "OGC 09-048"
        expect(result.doctype).to eq "other"
      end
    end
  end
end
