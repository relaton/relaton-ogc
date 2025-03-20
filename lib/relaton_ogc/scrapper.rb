module RelatonOgc
  module Scrapper
    TYPES = {
      "AS" => { type: "abstract-specification-topic" },
      "BP" => { type: "best-practice", subtype: "general" },
      "CAN" => { type: "standard", subtype: "general", stage: "draft" },
      # "CC" => "conformance-class",
      "CR" => { type: "change-request-supporting-document" },
      "CP" => { type: "community-practice" },
      "CS" => { type: "community-standard" },
      "DP" => { type: "discussion-paper" },
      "DP-Draft" => { type: "discussion-paper", stage: "draft" },
      "IPR" => { type: "engineering-report" },
      "IS" => { type: "standard", subtype: "implementation" },
      "ISC" => { type: "standard", subtype: "implementation" },
      "ISx" => { type: "standard", subtype: "extension" },
      "Notes" => { type: "other" },
      "ORM" => { type: "reference-model" },
      "PC" => { type: "standard", subtype: "profile" },
      "PER" => { type: "engineering-report" },
      "POL" => { type: "standard" },
      # "POLNTS" => "policy-name-type-specification",
      "Primer" => { type: "other" },
      "Profile" => { type: "standard", subtype: "profile" },
      "RFC" => { type: "standard", stage: "draft" },
      # "Retired" => "retired",
      "SAP" => { type: "standard", subtype: "profile" },
      # "TS" => "test-suite", # @PENDING
      "WhitePaper" => { type: "white-paper" },
      "ATB" => { type: "other" },
      "RP" => { type: "discussion-paper" },
    }.freeze

    class << self
      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        type = fetch_type(hit["type"])
        OgcBibliographicItem.new(
          type: "standard",
          title: fetch_title(hit["title"]),
          docid: fetch_docid(hit["identifier"]),
          link: fetch_link(hit),
          doctype: fetch_doctype(type[:type]),
          subdoctype: type[:subtype],
          docstatus: fetch_status(type[:stage]),
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
      # @return [Array<RelatonBib::TypedTitleString>]
      def fetch_title(title)
        RelatonBib::TypedTitleString.from_string title, "en", "Latn"
      end

      # @param identifier [String]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(identifier)
        [RelatonBib::DocumentIdentifier.new(id: identifier, type: "OGC", primary: true)]
      end

      # @param hit [Hash]
      # @return [Array>RelatonBib::TypedUri>]
      def fetch_link(hit)
        link = []
        uri = hit["URI"].to_s.strip
        link << RelatonBib::TypedUri.new(type: "src", content: uri) unless uri.empty?
        return link unless hit["URL"] && !hit["URL"].strip.empty?

        if ext = hit["URL"].match(/(?<=\.)(?<ext>pdf|html|doc)$/)
          type = ext[:ext]
        else
          case hit["URL"]
          when /portal\.(ogc|opengeospatial)\.org/, /usgif\.org/
            type = "pdf"
          when /www\.(w3|geopackage)\.org/, /docs\.ogc\.org/
            type = "html"
          else
            type = "html"
          end
        end
        link  << RelatonBib::TypedUri.new(type: type, content: hit["URL"].strip)
      end

      def fetch_doctype(type)
        DocumentType.new(type: type)
      end

      # @param type [String]
      # @return [String]
      def fetch_type(type)
        TYPES[type.sub(/^D-/, "")] || { type: "other" }
      end

      # @param stage [String]
      # @return [RelatonBib::DocumentStatus, nil]
      def fetch_status(stage)
        stage && RelatonBib::DocumentStatus.new(stage: stage)
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

      # @param date [String, nil]
      # @return [Array<RelatonBib::BibliographicDate>]
      def fetch_date(date)
        return [] unless date

        [RelatonBib::BibliographicDate.new(type: "published", on: date)]
      rescue Date::Error
        []
      end
    end
  end
end
