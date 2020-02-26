require "nokogiri"

module RelatonOgc
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      # Override RelatonIsoBib::XMLParser.form_xml method.
      # @param xml [String]
      # @return [RelatonOgc::OgcBibliographicItem]
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        isoitem = doc.at "/bibitem|/bibdata"
        if isoitem
          OgcBibliographicItem.new item_data(isoitem)
        else
          warn "[relato-ogc] can't find bibitem or bibdata element in the XML"
        end
      end

      private

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
