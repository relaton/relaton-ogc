RSpec.describe RelatonOgc::OgcBibliographicItem do
  it "warn invalid document subtype" do
    expect do
      RelatonOgc::OgcBibliographicItem.new docsubtype: "invalid-subtype"
    end.to output(/invalid document subtyp/).to_stderr
  end

  it "returns AciiBib" do
    hash = YAML.load_file "spec/fixtures/ogc_bib_item.yml"
    bib_hash = RelatonOgc::HashConverter.hash_to_bib hash
    item = RelatonOgc::OgcBibliographicItem.new(**bib_hash)
    expect(item.to_asciibib).to include <<~ASCIIBIB
      editorialgroup.committee:: technical
      editorialgroup.subcommittee.name:: Subcommittee
      editorialgroup.subcommittee.number:: 11
      editorialgroup.subcommittee.type:: OGC
      editorialgroup.workgroup.name:: Working
      editorialgroup.workgroup.number:: 22
      editorialgroup.workgroup.type:: WG
      docsubtype:: general
    ASCIIBIB
  end
end
