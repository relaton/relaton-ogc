RSpec.describe RelatonOgc::EditorialGroup do
  it "raise invalid committee error" do
    expect do
      RelatonOgc::EditorialGroup.new committee: "comm"
    end.to raise_error ArgumentError
  end
end
