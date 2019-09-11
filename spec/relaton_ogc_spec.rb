RSpec.describe RelatonOgc do
  it "has a version number" do
    expect(RelatonOgc::VERSION).not_to be nil
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
        result = RelatonOgc::OgcBibliography.get "12-128r14", nil, {}
        expect(result.doctype).to eq "implementation-standard"
      end
    end

    it "returns last date" do
      VCR.use_cassette "data" do
        result = RelatonOgc::OgcBibliography.get "16-079", nil, {}
        expect(result.doctype).to eq "implementation-standard"
      end
    end
  end
end
