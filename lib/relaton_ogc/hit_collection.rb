require "faraday"
require "relaton_ogc/hit"
require "fileutils"

module RelatonOgc
  class HitCollection < RelatonBib::HitCollection
    ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/"\
      "NamingAuthority/master/incubation/bibliography/bibliography.json".freeze
    DATADIR = File.expand_path ".relaton/ogc/", Dir.home
    DATAFILE = File.expand_path "bibliography.json", DATADIR
    ETAGFILE = File.expand_path "etag.txt", DATADIR

    # @param ref [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(ref, year = nil)
      super
      @array = from_json(ref).sort_by do |hit|
        begin
          hit.hit["date"] ? Date.parse(hit.hit["date"]) : Date.new
        rescue ArgumentError
          Date.parse "0000-01-01"
        end
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
    def fetch_data # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      h = {}
      h["If-None-Match"] = etag if etag
      resp = Faraday.new(ENDPOINT, headers: h).get
      # return if there aren't any changes since last fetching
      return if resp.status == 304
      unless resp.status == 200
        raise RelatonBib::RequestError, "Could not access #{ENDPOINT}"
      end

      FileUtils.mkdir_p DATADIR unless Dir.exist? DATADIR
      self.etag = resp[:etag]
      @data = JSON.parse resp.body
      File.write DATAFILE, @data.to_json, encoding: "UTF-8"
    end

    #
    # Read ETag form file
    #
    # @return [String, NilClass]
    def etag
      @etag ||= if File.exist? ETAGFILE
                  File.read ETAGFILE, encoding: "UTF-8"
                end
    end

    #
    # Save ETag to file
    #
    # @param tag [String]
    def etag=(e_tag)
      File.write ETAGFILE, e_tag, encoding: "UTF-8"
    end
  end
end
