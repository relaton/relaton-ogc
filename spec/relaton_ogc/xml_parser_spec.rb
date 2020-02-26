require "jing"

RSpec.describe RelatonOgc::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/fixtures/ogc_bib_item.xml", encoding: "UTF-8"
    item = RelatonOgc::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
    schema = Jing.new "spec/fixtures/isobib.rng"
    errors = schema.validate "spec/fixtures/ogc_bib_item.xml"
    expect(errors).to eq []
  end

  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonOgc::XMLParser.from_xml "" }.to output(/can't find bibitem/)
      .to_stderr
    expect(item).to be_nil
  end
end
