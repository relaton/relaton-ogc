require "faraday"
require "relaton_ogc/hit"

module RelatonOgc
  class HitCollection < RelatonBib::HitCollection
    ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/"\
      "NamingAuthority/master/incubation/bibliography/bibliography.json".freeze
    DATAFILE = File.expand_path "data/bibliography.json", __dir__
    ETAGFILE = File.expand_path "data/etag.txt", __dir__

    # @param ref [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(ref, year = nil, opts = {})
      @text = ref
      @year = year
      @fetched = false
      concat from_json(ref)
    end

    private

    #
    # Fetch data form json
    #
    # @param docid [String]
    def from_json(docid, **_opts)
      ref = docid.sub /^OGC\s/, ""
      data.select do |_k, doc|
        doc["identifier"] =~ Regexp.new(ref)
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
      resp = Faraday.new(ENDPOINT, headers: { "If-None-Match" => etag }).get
      # return if there aren't any changes since last fetching
      return unless resp.status == 200

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
