RSpec.describe "Data fetcher" do
  let!(:body) { File.read "spec/fixtures/data.json", encoding: "UTF-8" }

  before :each do
    expect(FileUtils).to receive(:mkdir_p).with("data")
    expect(File).to receive(:exist?).with(/etag\.txt/).and_return true
    expect(File).to receive(:read).with(/etag\.txt/, encoding: "UTF-8").and_return "1234"
    allow(File).to receive(:read).and_call_original
  end

  it "fetch all the documents" do
    resp = double "Faraday response", status: 200, body: body
    expect(resp).to receive(:[]).with(:etag).and_return "1234"
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    expect(File).to receive(:write).with("data/18-088.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with("data/21-037.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with(/etag\.txt/, "1234", encoding: "UTF-8")
    RelatonOgc::DataFetcher.fetch
  end

  it "no changes response" do
    resp = double "Faraday response", status: 304
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    expect(File).to_not receive(:write).with("data/18-088.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to_not receive(:write).with("data/21-037.yaml", kind_of(String), encoding: "UTF-8")
    RelatonOgc::DataFetcher.fetch
  end

  it "source unavailable" do
    resp = double "Faraday response", status: 500
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    expect(File).to_not receive(:write).with(/etag\.txt/, "1234", encoding: "UTF-8")
    expect { RelatonOgc::DataFetcher.fetch }.to raise_error RelatonBib::RequestError
  end

  it "log document parsing errors" do
    resp = double "Faraday response", status: 200, body: body
    expect(resp).to receive(:[]).with(:etag).and_return "1234"
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    allow(RelatonOgc::Scrapper).to receive(:parse_page).and_raise StandardError
    expect { RelatonOgc::DataFetcher.fetch }.to output(/Fetching document: 18-088/).to_stderr
  end

  it "log document exists" do
    body_dup = File.read "spec/fixtures/data_dup.json", encoding: "UTF-8"
    resp = double "Faraday response", status: 200, body: body_dup
    expect(resp).to receive(:[]).with(:etag).and_return "1234"
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    expect(File).to receive(:write).with("data/18-088.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with("data/21-037.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with(/etag\.txt/, "1234", encoding: "UTF-8")
    expect { RelatonOgc::DataFetcher.fetch }.to output(
      /\[relaton-ogc\] WARNING Duplicated documents: 18-088, 21-037/,
    ).to_stderr
  end
end
