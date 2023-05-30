require "relaton/processor"

module RelatonOgc
  class Processor < Relaton::Processor
    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_ogc
      @prefix = "OGC"
      @defaultprefix = %r{^OGC\s}
      @idtype = "OGC"
      @datasets = %w[ogc-naming-authority]
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonOgc::OgcBibliographicItem]
    def get(code, date = nil, opts = {})
      ::RelatonOgc::OgcBibliography.get(code, date, opts)
    end

    #
    # Fetch all the documents from a source
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
    end

    # @param xml [String]
    # @return [RelatonOgc::OgcBibliographicItem]
    def from_xml(xml)
      ::RelatonOgc::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonOgc::OgcBibliographicItem]
    def hash_to_bib(hash)
      ::RelatonOgc::OgcBibliographicItem.from_hash hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonOgc.grammar_hash
    end

    #
    # Remove index file
    #
    def remove_index_file
      Relaton::Index.find_or_create(:ogc, url: true, file: HitCollection::INDEX_FILE).remove_file
    end
  end
end
