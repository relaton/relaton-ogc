RSpec.describe RelatonOgc::OgcBibliography do
  it "raise reauesr error" do
    expect(File).to receive(:ctime).and_return Date.today.prev_day.to_time
    request = double
    expect(request).to receive(:get).and_raise Faraday::Error::ConnectionFailed.new(nil)
    expect(Faraday).to receive(:new).and_return request
    expect do
      RelatonOgc::OgcBibliography.search("ref")
    end.to raise_error RelatonBib::RequestError
  end
end
