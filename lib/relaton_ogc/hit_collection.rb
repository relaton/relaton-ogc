require "faraday"
require "relaton_ogc/hit"
require "fileutils"

module RelatonOgc
  class HitCollection < RelatonBib::HitCollection
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-ogc/main/".freeze
    INDEX_FILE = "index-v1.yaml".freeze

    # @param code [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(code, year = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      super
      @array = []
      return if code.nil? || code.empty?

      index = Relaton::Index.find_or_create :ogc, url: "#{ENDPOINT}index-v1.zip", file: INDEX_FILE
      row = index.search(code).min_by { |r| r[:id] }
      return unless row

      url = "#{ENDPOINT}#{row[:file]}"
      resp = Faraday.get(url) { |req| req.options.timeout = 10 }
      return unless resp.status == 200

      hash = YAML.safe_load(resp.body)
      hash["fetched"] = Date.today.to_s
      bib = OgcBibliographicItem.from_hash hash
      @array = [Hit.new(bib, self)]
    end
  end
end
