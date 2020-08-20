RSpec.describe RelatonOgc::OgcBibliographicItem do
  it "warn invalid document subtype" do
    expect do
      RelatonOgc::OgcBibliographicItem.new docsubtype: "invalid-subtype"
    end.to output(/invalid document subtyp/).to_stderr
  end

  it "returns AciiBib" do
    hash = YAML.load_file "spec/fixtures/ogc_bib_item.yml"
    bib_hash = RelatonOgc::HashConverter.hash_to_bib hash
    item = RelatonOgc::OgcBibliographicItem.new bib_hash
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
      .gsub(/(?<=fetched::\s)\d{4}-\d{2}-\d{2/, Date.today.to_s)
  end
end
