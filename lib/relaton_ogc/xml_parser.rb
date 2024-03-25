require "nokogiri"

module RelatonOgc
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      private

      # override RelatonIsoBib::IsoBibliographicItem.bib_item method
      # @param item_hash [Hash]
      # @return [RelatonOgc::OgcBibliographicItem]
      def bib_item(item_hash)
        OgcBibliographicItem.new(**item_hash)
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end

      # Override RelatonIsoBib::XMLParser.item_data method.
      # @param item [Nokogiri::XML::Element]
      # @returtn [Hash]
      # def item_data(item)
      #   data = super
      #   ext = item.at "./ext"
      #   return data unless ext

      #   data[:docsubtype] = ext.at("./docsubtype")&.text
      #   data
      # end

      # @TODO Organization doesn't recreated
      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(ext)
        eg = ext.at("./editorialgroup")
        return unless eg

        committe = eg&.at("committee")&.text
        sc = iso_subgroup eg&.at("subcommittee")
        wg = iso_subgroup eg&.at("workgroup")
        EditorialGroup.new(committee: committe, subcommittee: sc, workgroup: wg)
      end
    end
  end
end
