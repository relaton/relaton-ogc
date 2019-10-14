module RelatonOgc
  module Scrapper
    TYPES = {
      "AS" => "Abstract Specification",
      "BP" => "Best Practice",
      "CAN" => "Candidate Standard",
      "CC" => "Conformance Class",
      "CR" => "Change Request",
      "CS" => "Community Standard",
      "DP" => "Discussion Paper",
      "DP-Draft" => "Draft Discussion Paper",
      "IPR" => "Interoperability Program Report - Engineering Specification",
      "IS" => "Implementation Standard",
      "ISC" => "Implementation Standard Corrigendum",
      "ISx" => "Extension Package Standard",
      "Notes" => "Notes",
      "ORM" => "OGC Reference Model",
      "PC" => "Profile Corrigendum",
      "PER" => "Public Engineering Report",
      "POL" => "Policy",
      "POL-NTS" => "Policy - Name Type Specification",
      "Primer" => "Primer",
      "Profile" => "Profile",
      "RFC" => "Request for Comment",
      "Retired" => "Retired document",
      "SAP" => "Standard Application Profile",
      "TS" => "Test Suite",
      "WhitePaper" => "Whitepaper",
    }.freeze

    class << self
      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit)
        OgcBibliographicItem.new(
          fetched: Date.today.to_s,
          title: fetch_title(hit["title"]),
          docid: fetch_docid(hit["identifier"]),
          link: fetch_link(hit["URL"]),
          doctype: fetch_type(hit["type"]),
          edition: fetch_edition(hit["identifier"]),
          abstract: fetch_abstract(hit["description"]),
          contributor: fetch_contributor(hit),
          language: ["en"],
          script: ["Latn"],
          date: fetch_date(hit["date"]),
        )
      end

      private

      # @param title [String]
      # @return [Array<RelatonIsoBib::TypedTitleString>]
      def fetch_title(title)
        [
          RelatonIsoBib::TypedTitleString.new(
            type: "title-main", content: title, language: "en", script: "Latn",
            format: "text/plain"
          ),
          RelatonIsoBib::TypedTitleString.new(
            type: "main", content: title, language: "en", script: "Latn",
            format: "text/plain"
          ),
        ]
      end

      # @param identifier [String]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(identifier)
        [RelatonBib::DocumentIdentifier.new(id: identifier, type: "OGC")]
      end

      # @param url [String]
      # @return [Array>RelatonBib::TypedUri>]
      def fetch_link(url)
        [RelatonBib::TypedUri.new(type: "obp", content: url)]
      end

      # @param type [String]
      # @return [String]
      def fetch_type(type)
        TYPES[type.sub(/^D-/, "")].downcase.gsub " ", "-"
      end

      # @param identifier [String]
      # @return [String]
      def fetch_edition(identifier)
        %r{(?<=r)(?<edition>\d+)$} =~ identifier
        edition
      end

      # @param description [String]
      # @return [Array<RelatonBib::FormattedString>]
      def fetch_abstract(description)
        [RelatonBib::FormattedString.new(content: description, language: "en",
                                         script: "Latn")]
      end

      # @param doc [Hash]
      # @return [Array<RelatonBib::ContributionInfo>]
      def fetch_contributor(doc)
        contribs = doc["creator"].to_s.split(", ").map do |name|
          personn_contrib name
        end
        contribs << org_contrib(doc["publisher"]) if doc["publisher"]
      end

      # @param name [String]
      # @return [RelatonBib::ContributionInfo]
      def personn_contrib(name)
        fname = RelatonBib::FullName.new(
          completename: RelatonBib::LocalizedString.new(name),
        )
        entity = RelatonBib::Person.new(name: fname)
        RelatonBib::ContributionInfo.new(
          entity: entity, role: [type: "author"],
        )
      end

      # @param name [String]
      # @return [RelatonBib::ContributionInfo]
      def org_contrib(name)
        entity = RelatonBib::Organization.new(name: name)
        RelatonBib::ContributionInfo.new(
          entity: entity, role: [type: "publisher"],
        )
      end

      # @param date [String]
      # @return [Array<RelatonBib::BibliographicDate>]
      def fetch_date(date)
        [RelatonBib::BibliographicDate.new(type: "published", on: date)]
      end
    end
  end
end
