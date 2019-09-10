module RelatonOgc
  class Hit < RelatonBib::Hit
    # @return [RelatonNist::HitCollection]
    attr_reader :hit_collection

    # Parse page.
    # @return [RelatonNist::NistBliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page @hit
    end
  end
end
