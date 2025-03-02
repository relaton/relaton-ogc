module Relaton
  module Ogc
    class Doctype < Bib::Doctype
      attribute :content, :string, values: %w[
        abstract-specification-topic best-practice change-request-supporting-document
        community-practice community-standard discussion-paper engineering-report
        other policy reference-model release-notes standard user-guide white-paper
        test-suite draft-standard
      ]
    end
  end
end
