RSpec.describe RelatonOgc do
  before do
    RelatonOgc.instance_variable_set(:@configuration, nil)
    # Force to download index file
    allow_any_instance_of(Relaton::Index::Type).to receive(:actual?).and_return(false)
    allow_any_instance_of(Relaton::Index::FileIO).to receive(:check_file).and_return(nil)
  end

  it "has a version number" do
    expect(RelatonOgc::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonOgc.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "fetch hit" do
    allow(File).to receive(:exist?).with(/etag\.txt/).and_return(false)
    expect(File).to receive(:exist?).and_call_original.at_least :once
    VCR.use_cassette "ogc_19_025r1" do
      hit_collection = RelatonOgc::OgcBibliography.search("OGC 19-025r1")
      expect(hit_collection.fetched).to be_falsy
      expect(hit_collection.fetch).to be_instance_of RelatonOgc::HitCollection
      expect(hit_collection.fetched).to be_truthy
      expect(hit_collection.first).to be_instance_of RelatonOgc::Hit
    end
  end

  context "return xml of hit" do
    it "with bibdata root elemen" do
      VCR.use_cassette "ogc_19_025r1" do
        hits = RelatonOgc::OgcBibliography.search("OGC 19-025r1")
        path = "spec/fixtures/hit.xml"
        xml = hits.first.to_xml bibdata: true
        File.write path, xml, encoding: "UTF-8" unless File.exist? path
        expect(xml).to be_equivalent_to File.open(path, "r:UTF-8", &:read)
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        schema = Jing.new "grammars/relaton-ogc-compile.rng"
        errors = schema.validate path
        expect(errors).to eq []
      end
    end
  end

  context "get code" do
    it "with edition", vcr: "ogc_19_025r1" do
      expect do
        result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", nil, {}
        expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
        expect(result.docidentifier.first.id).to eq "19-025r1"
      end.to output(
        include("[relaton-ogc] INFO: (OGC 19-025r1) Fetching from Relaton repository ...",
                "[relaton-ogc] INFO: (OGC 19-025r1) Found: `19-025r1`"),
      ).to_stderr_from_any_process
    end

    it "with year", vcr: "ogc_19_025r1" do
      result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", "2019", {}
      expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
      expect(result.docidentifier.first.id).to eq "19-025r1"
    end

    it "with wrog year", vcr: "ogc_19_025r1" do
      expect do
        result = RelatonOgc::OgcBibliography.get "OGC 19-025r1", "2018", {}
        expect(result).to be_nil
      end.to output(
        include("[relaton-ogc] INFO: (OGC 19-025r1) Not found.",
                "[relaton-ogc] INFO: (OGC 19-025r1) There was no match for `2018`, though there were matches found for `2019`"),
      ).to_stderr_from_any_process
    end

    it "ignore CC types" do
      VCR.use_cassette "ogc_12_128r14" do
        path = "spec/fixtures/12_128r14.xml"
        result = RelatonOgc::OgcBibliography.get "12-128r14", nil, {}
        xml = result.to_xml bibdata: true
        File.write path, xml, encoding: "UTF-8" unless File.exist? path
        expect(xml).to be_equivalent_to File.read(path, encoding: "UTF-8")
          .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        schema = Jing.new "grammars/relaton-ogc-compile.rng"
        errors = schema.validate path
        expect(errors).to eq []
      end
    end

    it "returns last date" do
      VCR.use_cassette "ogc_16_079" do
        result = RelatonOgc::OgcBibliography.get "16-079", nil, {}
        expect(result.doctype.type).to eq "standard"
        expect(result.subdoctype).to eq "implementation"
      end
    end

    it "get OGC 15-043r3" do
      VCR.use_cassette "ogc_15_043r3" do
        result = RelatonOgc::OgcBibliography.get "OGC 15-043r3"
        expect(result).to be_instance_of RelatonOgc::OgcBibliographicItem
      end
    end

    it "get document with unknown type" do
      VCR.use_cassette "ogc_09_048r5" do
        result = RelatonOgc::OgcBibliography.get "OGC 09-048r5"
        expect(result.doctype.type).to eq "other"
      end
    end

    it "handle empty reference" do
      VCR.use_cassette "empty_ref" do
        result = RelatonOgc::OgcBibliography.get "OGC "
        expect(result).to be_nil
      end
    end
  end
end
