module RelatonOgc
  class OgcBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    TYPES = %w[
      standard standard-with-suite
      abstract-specification best-practice candidate-standard conformance-class
      change-request community-standard discussion-paper draft-discussion-paper
      interoperability-program-report implementation-standard
      public-engineering-report
    ].freeze
  end
end
