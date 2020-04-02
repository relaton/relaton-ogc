module RelatonOgc
  class OgcBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    TYPES = %w[
      abstract-specification-topic best-practice
      change-request-supporting-document
      community-practice community-standard discussion-paper engineering-report
      other policy reference-model release-notes standard user-guide white-paper
      test-suite
    ].freeze

    SUBTYPES = %w[
      conceptual-model conceptual-model-and-encoding
      conceptual-model-and-implementation encoding extension implementation
      profile profile-with-extension general
    ].freeze

    # @return [String]
    attr_reader :docsubtype

    # @param docsubtype [String]
    def initialize(**args)
      if args[:docsubtype] && !SUBTYPES.include?(args[:docsubtype])
        warn "[relaton-ogc] invalid document subtype: #{args[:docsubtype]}"
      end

      @docsubtype = args.delete :docsubtype
      super
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["docsubtype"] = docsubtype if docsubtype
      hash
    end
  end
end
