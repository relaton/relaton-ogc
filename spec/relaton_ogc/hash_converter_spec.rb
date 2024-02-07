RSpec.describe RelatonOgc::HashConverter do
  it "return hash" do
    # xml = File.read "spec/fixtures/ogc_bib_item.xml", encoding: "UTF-8"
    hash = YAML.load_file "spec/fixtures/ogc_bib_item.yml"
    item = RelatonOgc::OgcBibliographicItem.from_hash hash
    expect(item.to_hash).to eq hash
  end

  it "create doctype" do
    hash = { type: "standard", abbreviation: "ST" }
    doctype = RelatonOgc::HashConverter.send(:create_doctype, **hash)
    expect(doctype).to be_instance_of RelatonOgc::DocumentType
    expect(doctype.type).to eq "standard"
    expect(doctype.abbreviation).to eq "ST"
  end
end
