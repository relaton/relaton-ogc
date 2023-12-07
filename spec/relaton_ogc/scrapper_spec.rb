describe RelatonOgc::Scrapper do
  it "parse_page" do
    hit = { "type" => :type, "title" => :title, "identifier" => :identifier,
            "date" => :date, "description" => :description }
    expect(described_class).to receive(:fetch_type).with(:type)
      .and_return(type: :doctype, subtype: :subdoctype, stage: :draft)
    expect(described_class).to receive(:fetch_title).with(:title).and_return("Title")
    expect(described_class).to receive(:fetch_docid).with(:identifier).and_return(:docid)
    expect(described_class).to receive(:fetch_link).with(hit).and_return(:link)
    expect(described_class).to receive(:fetch_date).with(:date).and_return(:date)
    expect(described_class).to receive(:fetch_abstract).with(:description).and_return(:abstract)
    expect(described_class).to receive(:fetch_contributor).with(hit).and_return(:contributor)
    expect(described_class).to receive(:fetch_editorialgroup).and_return(:editorialgroup)
    expect(described_class).to receive(:fetch_edition).with(:identifier).and_return(:edition)
    expect(described_class).to receive(:fetch_status).with(:draft).and_return(:status)
    expect(described_class).to receive(:fetch_doctype).with(:doctype).and_return(:doctype)
    expect(RelatonOgc::OgcBibliographicItem).to receive(:new).with(
      type: "standard", title: "Title", docid: :docid, link: :link, doctype: :doctype,
      subdoctype: :subdoctype, docstatus: :status, edition: :edition, abstract: :abstract,
      contributor: :contributor, language: ["en"], script: ["Latn"], date: :date,
      editorialgroup: :editorialgroup
    )
    described_class.parse_page hit
  end

  it "fetch_editorialgroup" do
    eg = described_class.send :fetch_editorialgroup
    expect(eg).to be_instance_of RelatonOgc::EditorialGroup
    expect(eg.committee).to eq "technical"
  end

  it "fetch_title" do
    title = described_class.send :fetch_title, "Title"
    expect(title).to be_instance_of RelatonBib::TypedTitleStringCollection
    expect(title.first.title.content).to eq "Title"
    expect(title.first.title.language).to eq ["en"]
    expect(title.first.title.script).to eq ["Latn"]
  end

  it "fetch_docid" do
    doid = described_class.send :fetch_docid, "identifier"
    expect(doid).to be_instance_of Array
    expect(doid.first).to be_instance_of RelatonBib::DocumentIdentifier
    expect(doid.first.id).to eq "identifier"
    expect(doid.first.type).to eq "OGC"
    expect(doid.first.primary).to be true
  end

  context "fetch_link" do
    it "URI and URL" do
      hit = { "URI" => "uri", "URL" => "url" }
      link = described_class.send :fetch_link, hit
      expect(link).to be_instance_of Array
      expect(link.size).to eq 2
      expect(link.first).to be_instance_of RelatonBib::TypedUri
      expect(link.first.type).to eq "src"
      expect(link.first.content.to_s).to eq "uri"
      expect(link.last).to be_instance_of RelatonBib::TypedUri
      expect(link.last.type).to eq "obp"
      expect(link.last.content.to_s).to eq "url"
    end

    it "URI only" do
      hit = { "URI" => "uri" }
      link = described_class.send :fetch_link, hit
      expect(link).to be_instance_of Array
      expect(link.size).to eq 1
      expect(link.first).to be_instance_of RelatonBib::TypedUri
      expect(link.first.type).to eq "src"
      expect(link.first.content.to_s).to eq "uri"
    end

    it "URL only" do
      hit = { "URL" => "url.pdf" }
      link = described_class.send :fetch_link, hit
      expect(link).to be_instance_of Array
      expect(link.size).to eq 1
      expect(link.first).to be_instance_of RelatonBib::TypedUri
      expect(link.first.type).to eq "pdf"
      expect(link.first.content.to_s).to eq "url.pdf"
    end
  end

  it "fetch_type" do
    type = described_class.send :fetch_type, "D-CAN"
    expect(type).to eq type: "standard", subtype: "general", stage: "draft"
  end

  it "fetch_doctype" do
    doctype = described_class.send :fetch_doctype, "standard"
    expect(doctype).to be_instance_of RelatonOgc::DocumentType
    expect(doctype.type).to eq "standard"
  end

  context "fetch_status" do
    it do
      status = described_class.send :fetch_status, "draft"
      expect(status).to be_instance_of RelatonBib::DocumentStatus
      expect(status.stage.value).to eq "draft"
    end

    it "nil" do
      expect(described_class.send(:fetch_status, nil)).to be_nil
    end
  end

  it "fetch_edition" do
    expect(described_class.send(:fetch_edition, "r5")).to eq "5"
  end

  it "fetch_abstract" do
    abstract = described_class.send :fetch_abstract, "description"
    expect(abstract).to be_instance_of Array
    expect(abstract.first).to be_instance_of RelatonBib::FormattedString
    expect(abstract.first.content).to eq "description"
    expect(abstract.first.language).to eq ["en"]
    expect(abstract.first.script).to eq ["Latn"]
  end

  it "fetch_contributor" do
    doc = { "creator" => "Person1, Person2", "publisher" => "Org" }
    expect(subject).to receive(:personn_contrib).with("Person1").and_return(:person1)
    expect(subject).to receive(:personn_contrib).with("Person2").and_return(:person2)
    expect(subject).to receive(:org_contrib).with("Org").and_return(:org)
    contrib = described_class.send :fetch_contributor, doc
    expect(contrib).to eq %i[person1 person2 org]
  end

  it "personn_contrib" do
    contrib = described_class.send :personn_contrib, "Person"
    expect(contrib).to be_instance_of RelatonBib::ContributionInfo
    expect(contrib.entity).to be_instance_of RelatonBib::Person
    expect(contrib.entity.name.completename.content).to eq "Person"
    expect(contrib.role.first.type).to eq "author"
  end

  it "org_contrib" do
    contrib = described_class.send :org_contrib, "Org"
    expect(contrib).to be_instance_of RelatonBib::ContributionInfo
    expect(contrib.entity).to be_instance_of RelatonBib::Organization
    expect(contrib.entity.name.first.content).to eq "Org"
    expect(contrib.role.first.type).to eq "publisher"
  end

  context "fetch_date" do
    it do
      date = described_class.send :fetch_date, "2019-01-01"
      expect(date).to be_instance_of Array
      expect(date.first).to be_instance_of RelatonBib::BibliographicDate
      expect(date.first.on).to eq "2019-01-01"
    end

    it "no date" do
      expect(described_class.send(:fetch_date, nil)).to eq []
    end

    it "invalid date" do
      date = described_class.send :fetch_date, "0000-00-00"
      expect(date).to eq []
    end
  end
end
