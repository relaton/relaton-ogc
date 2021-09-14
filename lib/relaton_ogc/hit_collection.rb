require "faraday"
require "relaton_ogc/hit"
require "fileutils"

module RelatonOgc
  class HitCollection < RelatonBib::HitCollection
    include DataFetcher::Utils

    # ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/"\
    #            "NamingAuthority/master/incubation/bibliography/"\
    #            "bibliography.json".freeze
    DATADIR = File.expand_path ".relaton/ogc/", Dir.home
    DATAFILE = File.expand_path "bibliography.json", DATADIR
    # ETAGFILE = File.expand_path "etag.txt", DATADIR

    # @param ref [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(ref, year = nil)
      super
      @etagfile = File.expand_path "etag.txt", DATADIR
      @array = from_json(ref).sort_by do |hit|
        hit.hit["date"] ? Date.parse(hit.hit["date"]) : Date.new
      rescue ArgumentError
        Date.parse "0000-01-01"
      end.reverse
    end

    private

    #
    # Fetch data form json
    #
    # @param docid [String]
    def from_json(docid, **_opts)
      ref = docid.sub(/^OGC\s/, "").strip
      return [] if ref.empty?

      data.select do |_k, doc|
        doc["type"] != "CC" && doc["identifier"].include?(ref)
      end.map { |_k, h| Hit.new(h, self) }
    end

    #
    # Fetches json data
    #
    # @return [Hash]
    def data
      ctime = File.ctime DATAFILE if File.exist? DATAFILE
      fetch_data if !ctime || ctime.to_date < Date.today
      @data ||= JSON.parse File.read(DATAFILE, encoding: "UTF-8")
    end

    #
    # fetch data form server and save it to file.
    #
    def fetch_data
      json = get_data
      return unless json

      FileUtils.mkdir_p DATADIR unless Dir.exist? DATADIR
      @data = json
      File.write DATAFILE, @data.to_json, encoding: "UTF-8"
    end
  end
end
