module RelatonOgc
  class OgcBibliographicItem < RelatonBib::BibliographicItem
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
        warn "[relaton-ogc] WARNING: invalid document subtype: #{args[:docsubtype]}"
      end

      @docsubtype = args.delete :docsubtype
      super
      # @doctype = args[:doctype]
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["docsubtype"] = docsubtype if docsubtype
      hash
    end

    # @param builder [Nokogiri::XML::Builder]
    # @param opts [Hash]
    # @option opts [Boolean] :bibdata
    def to_xml(builder = nil, **opts)
      super do |b|
        b.ext do
          b.doctype doctype if doctype
          b.docsubtype docsubtype if docsubtype
          editorialgroup&.to_xml b
          ics.each { |i| i.to_xml b }
        end
      end
    end
  end
end
