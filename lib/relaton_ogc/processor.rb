require "relaton/processor"

module RelatonOgc
  class Processor < Relaton::Processor
    def initialize
      @short = :relaton_ogc
      @prefix = "OGC"
      @defaultprefix = %r{^OGC\s}
      @idtype = "OGC"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonOgc::OgcBibliographicItem]
    def get(code, date = nil, opts = {})
      ::RelatonOgc::OgcBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonOgc::OgcBibliographicItem]
    def from_xml(xml)
      ::RelatonOgc::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonOgc::OgcBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonOgc::HashConverter.hash_to_bib(hash)
      ::RelatonOgc::OgcBibliographicItem.new item_hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonOgc.grammar_hash
    end
  end
end
