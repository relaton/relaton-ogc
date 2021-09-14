module RelatonOgc
  class DataFetcher
    module Utils
      ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/"\
                 "NamingAuthority/master/incubation/bibliography/"\
                 "bibliography.json".freeze

      def get_data # rubocop:disable Metrics/AbcSize
        h = {}
        h["If-None-Match"] = etag if etag
        resp = Faraday.new(ENDPOINT, headers: h).get
        case resp.status
        when 200
          json = JSON.parse(resp.body)
          block_given? ? yield(resp[:etag], json) : json
        when 304 then [] # there aren't any changes since last fetching
        else raise RelatonBib::RequestError, "Could not access #{ENDPOINT}"
        end
      end

      #
      # Read ETag form file
      #
      # @return [String, NilClass]
      def etag
        @etag ||= if File.exist? @etagfile
                    File.read @etagfile, encoding: "UTF-8"
                  end
      end

      #
      # Save ETag to file
      #
      # @param tag [String]
      def etag=(e_tag)
        File.write @etagfile, e_tag, encoding: "UTF-8"
      end
    end

    include Utils

    #
    # Create DataFetcher instance
    #
    # @param [String] output directory to save the documents
    # @param [String] format output format "yaml" or "xmo"
    #
    def initialize(output, format)
      @output = output
      @etagfile = File.join output, "etag.txt"
      @format = format
      @docids = []
      @dupids = []
    end

    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output unless Dir.exist? output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    def fetch # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      get_data do |etag, json|
        no_errors = true
        json.each do |_, hit|
          bib = Scrapper.parse_page hit
          write_document bib
        rescue StandardError => e
          no_errors = false
          warn "Fetching document: #{hit['identifier']}"
          warn "#{e.class} #{e.message}"
          warn e.backtrace
        end
        warn "[relaton-ogc] WARNING Duplicated documents: #{@dupids.uniq.join(', ')}" if @dupids.any?
        self.etag = etag if no_errors
      end
    end

    def write_document(bib) # rubocop:disable Metrics/AbcSize
      if @docids.include?(bib.docidentifier[0].id)
        @dupids << bib.docidentifier[0].id
        return
      end

      @docids << bib.docidentifier[0].id
      name = bib.docidentifier[0].id.upcase.gsub(/[\s:.]/, "_")
      file = "#{@output}/#{name}.#{@format}"
      content = @format == "xml" ? bib.to_xml(bibdata: true) : bib.to_hash.to_yaml
      File.write file, content, encoding: "UTF-8"
    end
  end
end
