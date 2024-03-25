describe RelatonOgc::DocumentType do
  it "warns if doctype is invalid" do
    expect do
      RelatonOgc::DocumentType.new type: "invalid"
    end.to output(/\[relaton-ogc\] WARN: invalid doctype: `invalid`/).to_stderr_from_any_process
  end
end
