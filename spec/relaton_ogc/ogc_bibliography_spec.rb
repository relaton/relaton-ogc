RSpec.describe RelatonOgc::OgcBibliography do
  it "raise request error" do
    expect(RelatonOgc::HitCollection).to receive(:new).and_raise Faraday::ConnectionFailed.new(nil)
    expect do
      RelatonOgc::OgcBibliography.search("ref")
    end.to raise_error RelatonBib::RequestError
  end
end
