RSpec.describe RelatonOgc::OgcBibliographicItem do
  it "warn invalid document subtype" do
    expect do
      RelatonOgc::OgcBibliographicItem.new docsubtype: "invalid-subtype"
    end.to output(/invalid document subtyp/).to_stderr
  end
end
