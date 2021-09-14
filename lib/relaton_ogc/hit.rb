module RelatonOgc
  class Hit < RelatonBib::Hit
    #
    # <Description>
    #
    # @param [RelatonOgc::OgcBibliographicItem] bibitem
    # @param [RelatonOgc::HitCollection, nil] hitcoll
    #
    def initialize(bibitem, hitcoll = nil)
      super({ id: bibitem.docidentifier[0].id}, hitcoll)
      @fetch = bibitem
    end

    # Parse page.
    # @return [RelatonNist::NistBliographicItem]
    def fetch
      @fetch # ||= Scrapper.parse_page @hit
    end
  end
end
