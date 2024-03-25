module RelatonOgc
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[
      abstract-specification-topic best-practice
      change-request-supporting-document
      community-practice community-standard discussion-paper engineering-report
      other policy reference-model release-notes standard user-guide white-paper
      test-suite draft-standard
    ].freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      super
    end

    def check_type(type)
      unless DOCTYPES.include? type
        Util.warn "invalid doctype: `#{type}`"
      end
    end
  end
end
