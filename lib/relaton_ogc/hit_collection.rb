require "faraday"
require "relaton_ogc/hit"
require "fileutils"

module RelatonOgc
  class HitCollection < RelatonBib::HitCollection
    # include DataFetcher::Utils

    # ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/"\
    #            "NamingAuthority/master/incubation/bibliography/"\
    #            "bibliography.json".freeze
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-ogc/main/data/".freeze
    # DATADIR = File.expand_path ".relaton/ogc/", Dir.home
    # DATAFILE = File.expand_path "bibliography.json", DATADIR
    # ETAGFILE = File.expand_path "etag.txt", DATADIR

    # @param code [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(code, year = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      super
      # @etagfile = File.expand_path "etag.txt", DATADIR
      # @array = from_json(ref).sort_by do |hit|
      #   hit.hit["date"] ? Date.parse(hit.hit["date"]) : Date.new
      # rescue ArgumentError
      #   Date.parse "0000-01-01"
      # end.reverse
      url = "#{ENDPOINT}#{code.upcase.gsub(/[\s:.]/, '_')}.yaml"
      resp = Faraday.get url do |req|
        req.options.timeout = 10
      end
      @array = case resp.status
               when 200
                 hash = YAML.safe_load(resp.body)
                 hash["fetched"] = Date.today.to_s
                 bib = OgcBibliographicItem.from_hash hash
                 [Hit.new(bib, self)]
               else []
               end
    end

    # private

    #
    # Fetch data form json
    #
    # @param docid [String]
    # def from_json(docid, **_opts)
    #   ref = docid.sub(/^OGC\s/, "").strip
    #   return [] if ref.empty?

    #   data.select do |_k, doc|
    #     doc["type"] != "CC" && doc["identifier"].include?(ref)
    #   end.map { |_k, h| Hit.new(h, self) }
    # end

    #
    # Fetches json data
    #
    # @return [Hash]
    # def data
    #   ctime = File.ctime DATAFILE if File.exist? DATAFILE
    #   fetch_data if !ctime || ctime.to_date < Date.today
    #   @data ||= JSON.parse File.read(DATAFILE, encoding: "UTF-8")
    # end

    #
    # fetch data form server and save it to file.
    #
    # def fetch_data
    #   json = get_data
    #   return unless json

    #   FileUtils.mkdir_p DATADIR unless Dir.exist? DATADIR
    #   @data = json
    #   File.write DATAFILE, @data.to_json, encoding: "UTF-8"
    # end
  end
end
