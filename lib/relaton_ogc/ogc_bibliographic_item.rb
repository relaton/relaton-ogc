module RelatonOgc
  class OgcBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    TYPES = %w[
      abstract-specification best-practice candidate-standard conformance-class
      change-request community-practice community-standard discussion-paper
      draft-discussion-paper interoperability-program-report implementation-standard
      implementation-standard-corrigendum extension-package-standard notes
      ogc-reference-model profile-corrigendum public-engineering-report policy
      policy-name-type-specification primer profile request-for-comment retired
      standard-application-profile test-suite whitepaper approved-technical-baseline
      recommendation-paper
    ].freeze
  end
end
