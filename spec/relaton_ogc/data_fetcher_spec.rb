RSpec.describe RelatonOgc::DataFetcher do
  it "initializes" do
    df = described_class.new "data", "bibxml"
    expect(df.instance_variable_get(:@output)).to eq "data"
    expect(df.instance_variable_get(:@etagfile)).to eq "data/etag.txt"
    expect(df.instance_variable_get(:@format)).to eq "bibxml"
    expect(df.instance_variable_get(:@ext)).to eq "xml"
    expect(df.instance_variable_get(:@docids)).to eq []
    expect(df.instance_variable_get(:@dupids)).to eq Set.new
  end

  it "::fetch" do
    expect(FileUtils).to receive(:mkdir_p).with("data")
    df = double "DataFetcher instance"
    expect(df).to receive(:fetch)
    expect(described_class).to receive(:new).with("data", "yaml").and_return df
    described_class.fetch
  end

  context "instance methods" do
    subject { described_class.new "data", "yaml" }
    let (:bib) { double "BibliographicItem", docidentifier: [double("DocIdentifier", id: "1")] }

    it "#index" do
      expect(subject.index).to be_instance_of Relaton::Index::Type
    end

    context "#fetch" do
      before do
        expect(subject).to receive(:get_data).and_yield "etag", { "1" => :hit }
        expect(subject.index).to receive(:save)
      end

      it do
        expect(subject).to receive(:fetch_doc).with(:hit).and_return true
        expect(subject).to receive(:etag=).with("etag")
        subject.fetch
      end

      it "error" do
        expect(subject).to receive(:fetch_doc).with(:hit).and_return false
        expect(subject).not_to receive(:etag=).with("etag")
        subject.fetch
      end

      it "duplicated" do
        subject.instance_variable_set :@dupids, ["1"]
        expect(subject).to receive(:fetch_doc).with(:hit).and_return true
        expect(subject).to receive(:etag=).with("etag")
        expect { subject.fetch }.to output(/\[relaton-ogc\] WARNING Duplicated documents: 1/).to_stderr
      end
    end

    context "#fetch_doc" do
      it "no errors" do
        hit = { "type" => "BP" }
        expect(RelatonOgc::Scrapper).to receive(:parse_page).with(hit).and_return :doc
        expect(subject).to receive(:write_document).with(:doc)
        expect(subject.fetch_doc(hit)).to be true
      end

      it "CC type" do
        expect(RelatonOgc::Scrapper).not_to receive(:parse_page)
        expect(subject.fetch_doc("type" => "CC")).to be nil
      end

      it "error" do
        expect(RelatonOgc::Scrapper).to receive(:parse_page).and_raise StandardError
        expect { subject.fetch_doc({}) }.to output(/Fetching document: /).to_stderr
      end
    end

    context "#write_document" do
      it "no duplicate" do
        expect(subject.index).to receive(:add_or_update).with("1", "data/1.yaml")
        expect(subject).to receive(:content).with(bib).and_return :content
        expect(File).to receive(:write).with("data/1.yaml", :content, encoding: "UTF-8")
        subject.write_document bib
        expect(subject.instance_variable_get(:@docids)).to eq ["1"]
      end

      it "duplicate" do
        subject.instance_variable_set :@docids, ["1"]
        expect(subject.index).not_to receive(:add_or_update)
        subject.write_document bib
        expect(subject.instance_variable_get(:@dupids)).to eq Set["1"]
      end
    end

    context "#content" do
      it "yaml" do
        hash = double "Hash"
        expect(hash).to receive(:to_yaml).and_return :yaml
        expect(bib).to receive(:to_hash).and_return hash
        expect(subject.content(bib)).to eq :yaml
      end

      it "xml" do
        subject.instance_variable_set :@format, "xml"
        subject.instance_variable_set :@ext, "xml"
        expect(bib).to receive(:to_xml).with(bibdata: true).and_return :xml
        expect(subject.content(bib)).to eq :xml
      end

      it "bibxml" do
        subject.instance_variable_set :@format, "bibxml"
        subject.instance_variable_set :@ext, "xml"
        expect(bib).to receive(:to_bibxml).and_return :bibxml
        expect(subject.content(bib)).to eq :bibxml
      end
    end

    context "#file_name" do
      it("yaml") { expect(subject.file_name(bib)).to eq "data/1.yaml" }

      it "xml" do
        subject.instance_variable_set :@ext, "xml"
        expect(subject.file_name(bib)).to eq "data/1.xml"
      end
    end

    describe "Utils" do
      context "#get_data" do
        it "200" do
          expect(subject).to receive(:etag).and_return("etag").twice
          data = { "title" => "title" }
          resp = double "Faraday response", status: 200, body: data.to_json
          faraday = double "Faraday instance"
          expect(faraday).to receive(:get).and_return resp
          expect(Faraday).to receive(:new).with(kind_of(String), headers: { "If-None-Match" => "etag"}).and_return faraday
          expect(subject.get_data).to eq data
        end

        it "304" do
          resp = double "Faraday response", status: 304
          faraday = double "Faraday instance", get: resp
          expect(Faraday).to receive(:new).and_return faraday
          expect(File).to_not receive(:write)
          expect(subject.send(:get_data)).to eq []
        end

        it "500" do
          resp = double "Faraday response", status: 500
          faraday = double "Faraday instance", get: resp
          expect(Faraday).to receive(:new).and_return faraday
          expect(File).to_not receive(:write)
          expect { subject.send(:get_data) }.to raise_error RelatonBib::RequestError
        end
      end

      it "#etag" do
        expect(File).to receive(:exist?).with("data/etag.txt").and_return true
        expect(File).to receive(:read).with("data/etag.txt", encoding: "UTF-8").and_return "etag"
        expect(subject.etag).to eq "etag"
      end

      it "#etag=" do
        expect(File).to receive(:write).with("data/etag.txt", "etag", encoding: "UTF-8")
        subject.etag = "etag"
      end
    end
  end
end
