RSpec.describe RelatonOgc::OgcBibliographicItem do
  it "warn invalid document subtype" do
    expect do
      RelatonOgc::OgcBibliographicItem.new subdoctype: "invalid-subtype"
    end.to output(/\[relaton-ogc\] WARNING: Invalid document subtype: `invalid-subtype`/).to_stderr_from_any_process
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
    ASCIIBIB
  end
end
