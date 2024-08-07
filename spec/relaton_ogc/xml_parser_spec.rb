require "jing"

RSpec.describe RelatonOgc::XMLParser do
  it "creates item form xml" do
    path = "spec/fixtures/12_128r14.xml"
    xml = File.read path, encoding: "UTF-8"
    item = RelatonOgc::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
    schema = Jing.new "grammars/relaton-ogc-compile.rng"
    errors = schema.validate path
    expect(errors).to eq []
  end

  # it "warn if XML doesn't have bibitem or bibdata element" do
  #   item = ""
  #   expect { item = RelatonOgc::XMLParser.from_xml "" }.to output(/can't find bibitem/)
  #     .to_stderr
  #   expect(item).to be_nil
  # end

  it "creates doctype" do
    xml = Nokogiri::XML(<<~XML).at("/doctype")
      <doctype abbreviation="ST">standard</doctype>
    XML
    doctype = RelatonOgc::XMLParser.send :create_doctype, xml
    expect(doctype).to be_instance_of RelatonOgc::DocumentType
    expect(doctype.type).to eq "standard"
    expect(doctype.abbreviation).to eq "ST"
  end
end
