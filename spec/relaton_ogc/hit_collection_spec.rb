RSpec.describe RelatonOgc::HitCollection do
  it "fetch data from server" do
    expect(File).to receive(:ctime).and_return(Date.today.prev_day.to_time)
      .at_most(:once)
    expect(File).to receive(:write).twice
    expect(File).to receive(:read).with(
      RelatonOgc::HitCollection::ETAGFILE, encoding: "UTF-8"
    ).and_return("old_etag").at_most(:once)
    VCR.use_cassette "update_data" do
      RelatonOgc::OgcBibliography.search("19-025r1")
    end
  end
end
