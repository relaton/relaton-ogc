module RelatonOgc
  class Hit < RelatonBib::Hit
    # Parse page.
    # @return [RelatonNist::NistBliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page @hit
    end
  end
end
