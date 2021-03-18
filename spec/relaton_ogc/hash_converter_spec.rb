RSpec.describe RelatonOgc::HashConverter do
  it "return hash" do
    # xml = File.read "spec/fixtures/ogc_bib_item.xml", encoding: "UTF-8"
    hash = YAML.load_file "spec/fixtures/ogc_bib_item.yml"
    bib = RelatonOgc::HashConverter.hash_to_bib hash
    item = RelatonOgc::OgcBibliographicItem.new **bib
    expect(item.to_hash).to eq hash
  end
end
