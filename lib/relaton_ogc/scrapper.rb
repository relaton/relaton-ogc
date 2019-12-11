module RelatonOgc
  module Scrapper
    TYPES = {
      "AS" => "abstract-specification",
      "BP" => "best-practice",
      "CAN" => "candidate-standard",
      "CC" => "conformance-class",
      "CR" => "change-request",
      "CP" => "community-practice",
      "CS" => "community-standard",
      "DP" => "discussion-paper",
      "DP-Draft" => "draft-discussion-paper",
      "IPR" => "interoperability-program-report",
      "IS" => "implementation-standard",
      "ISC" => "implementation-standard-corrigendum",
      "ISx" => "extension-package-standard",
      "Notes" => "notes",
      "ORM" => "ogc-reference-model",
      "PC" => "profile-corrigendum",
      "PER" => "public-engineering-report",
      "POL" => "policy",
      "POLNTS" => "policy-name-type-specification",
      "Primer" => "primer",
      "Profile" => "profile",
      "RFC" => "request-for-comment",
      "Retired" => "retired",
      "SAP" => "standard-application-profile",
      "TS" => "test-suite",
      "WhitePaper" => "whitepaper",
      "ATB" => "approved-technical-baseline",
      "RP" => "recommendation-paper",
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
          editorialgroup: fetch_editorialgroup,
        )
      end

      private

      def fetch_editorialgroup
        EditorialGroup.new committee: "technical"
      end

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
        TYPES[type.sub(/^D-/, "")]
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
