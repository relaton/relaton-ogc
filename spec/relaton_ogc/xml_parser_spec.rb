RSpec.describe RelatonOgc::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/fixtures/ogc_bib_item.xml", encoding: "UTF-8"
    item = RelatonOgc::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end
end
