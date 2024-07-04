# frozen_string_literal: true

module RelatonOgc
  class DataFetcher
    module Utils
      ENDPOINT = "https://raw.githubusercontent.com/opengeospatial/NamingAuthority/master/definitions/docs/docs.json"

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
    # @param [String] format output format "yaml", "xml", or "bibxml"
    #
    def initialize(output, format)
      @output = output
      @etagfile = File.join output, "etag.txt"
      @format = format
      @ext = format.sub "bib", ""
      @docids = []
      @dupids = Set.new
    end

    def index
      @index ||= Relaton::Index.find_or_create :ogc, file: "index-v1.yaml"
    end

    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    def fetch
      get_data do |etag, json|
        no_errors = true
        json.each { |_, hit| fetch_doc(hit) || no_errors = false }
        Util.warn "Duplicated documents: #{@dupids.to_a.join(', ')}" if @dupids.any?
        self.etag = etag if no_errors
        index.save
      end
    end

    def fetch_doc(hit)
      return if hit["type"] == "CC"

      bib = Scrapper.parse_page hit
      write_document bib
      true
    rescue StandardError => e
      Util.error "Fetching document: #{hit['identifier']}\n" \
      "#{e.class} #{e.message}\n#{e.backtrace}"
      false
    end

    def write_document(bib) # rubocop:disable Metrics/AbcSize
      if @docids.include?(bib.docidentifier[0].id)
        @dupids << bib.docidentifier[0].id
        return
      end

      @docids << bib.docidentifier[0].id
      file = file_name bib
      index.add_or_update bib.docidentifier[0].id, file
      File.write file, content(bib), encoding: "UTF-8"
    end

    def file_name(bib)
      name = bib.docidentifier[0].id.upcase.gsub(/[\s:.]/, "_")
      "#{@output}/#{name}.#{@ext}"
    end

    def content(bib)
      case @format
      when "xml" then bib.to_xml bibdata: true
      when "yaml" then bib.to_hash.to_yaml
      when "bibxml" then bib.to_bibxml
      end
    end
  end
end
