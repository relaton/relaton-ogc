module RelatonOgc
  class OgcBibliographicItem < RelatonBib::BibliographicItem
    SUBTYPES = %w[
      conceptual-model conceptual-model-and-encoding
      conceptual-model-and-implementation encoding extension implementation
      profile profile-with-extension general
    ].freeze

    def initialize(**args)
      if args[:subdoctype] && !SUBTYPES.include?(args[:subdoctype])
        Util.warn "Invalid document subtype: `#{args[:subdoctype]}`"
      end

      # @docsubtype = args.delete :docsubtype
      # @doctype = args.delete :doctype
      super
    end

    #
    # Fetches flavof schema version
    #
    # @return [String] schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-ogc"]
    end

    # @param hash [Hash]
    # @return [RelatonOgc::OgcBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonOgc::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end

    # @return [Hash]
    # def to_hash
    #   hash = super
    #   hash["docsubtype"] = docsubtype if docsubtype
    #   hash
    # end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [Symbol, NilClass] :date_format (:short), :full
    # @option opts [String, Symbol] :lang language
    # @return [String] XML
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize
      super(**opts) do |b|
        ext = b.ext do
          doctype&.to_xml b
          b.subdoctype subdoctype if subdoctype
          editorialgroup&.to_xml b
          ics.each { |i| i.to_xml b }
        end
        ext["schema-version"] = ext_schema unless opts[:embedded]
      end
    end

    # @param prefix [String]
    # @return [String]
    # def to_asciibib(prefix = "")
    #   pref = prefix.empty? ? prefix : prefix + "."
    #   out = super
    #   out += "#{pref}docsubtype:: #{docsubtype}\n" if docsubtype
    #   out
    # end
  end
end
