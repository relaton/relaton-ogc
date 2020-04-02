require "nokogiri"

module RelatonOgc
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      # Override RelatonIsoBib::XMLParser.form_xml method.
      # @param xml [String]
      # @return [RelatonOgc::OgcBibliographicItem]
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        item = doc.at "/bibitem|/bibdata"
        if item
          OgcBibliographicItem.new item_data(item)
        else
          warn "[relaton-ogc] can't find bibitem or bibdata element in the XML"
        end
      end

      private

      # Override RelatonIsoBib::XMLParser.item_data method.
      # @param item [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(item)
        data = super
        ext = item.at "./ext"
        return data unless ext

        data[:docsubtype] = ext.at("./docsubtype")&.text
        data
      end

      # @TODO Organization doesn't recreated
      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(ext)
        eg = ext.at("./editorialgroup")
        return unless eg

        committe = eg&.at("committee")&.text
        sc = iso_subgroup eg&.at("subcommittee")
        wg = iso_subgroup eg&.at("workgroup")
        EditorialGroup.new(
          committee: committe, subcommittee: sc, workgroup: wg,
        )
      end
    end
  end
end
