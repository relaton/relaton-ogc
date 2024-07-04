module RelatonOgc
  class OgcBibliography
    class << self
      # @param text [String]
      # @return [RelatonOgc::HitCollection]
      def search(text, year = nil, _opts = {})
        code = text.sub(/^OGC\s/, "")
        HitCollection.new code, year
      rescue Faraday::ConnectionFailed, Faraday::SSLError
        raise RelatonBib::RequestError, HitCollection::ENDPOINT
      end

      # @param code [String] the OGC standard Code to look up (e..g "8200")
      # @param year [String] the year the standard was published (optional)
      #
      # @param opts [Hash] options
      # @option opts [TrueClass, FalseClass] :all_parts restricted to all parts
      #   if all-parts reference is required
      # @option opts [TrueClass, FalseClass] :bibdata
      #
      # @return [String] Relaton XML serialisation of reference
      def get(code, year = nil, opts = {})
        # id = year ? "`#{code}` year `#{year}`" : "#`{code}`"
        result = bib_search_filter(code, year, opts) || (return nil)
        ret = bib_results_filter(result, year)
        if ret[:ret]
          Util.info "Found: `#{ret[:ret].docidentifier.first.id}`", key: code
          ret[:ret]
        else
          fetch_ref_err(code, year, ret[:years])
        end
      end

      private

      def bib_search_filter(code, year, opts)
        Util.info "Fetching from Relaton repository ...", key: code
        search(code, year, opts)
      end

      # Sort through the results from RelatonNist, fetching them three at a time,
      # and return the first result that matches the code,
      # matches the year (if provided), and which # has a title (amendments do not).
      # Only expects the first page of results to be populated.
      # Does not match corrigenda etc (e.g. ISO 3166-1:2006/Cor 1:2007)
      # If no match, returns any years which caused mismatch, for error reporting
      #
      # @param result
      # @param opts [Hash] options
      #
      # @return [Hash]
      def bib_results_filter(result, year)
        missed_years = []
        result.each do |r|
          item = r.fetch
          return { ret: item } if !year

          item.date.select { |d| d.type == "published" }.each do |d|
            return { ret: item } if year.to_i == d.on(:year)

            missed_years << d.on(:year)
          end
        end
        { years: missed_years }
      end

      # @param code [Strig]
      # @param year [String]
      # @param missed_years [Array<Strig>]
      def fetch_ref_err(code, year, missed_years)
        Util.info "Not found.", key: code
        unless missed_years.empty?
          Util.info "There was no match for `#{year}`, though there " \
                    "were matches found for `#{missed_years.join('`, `')}`.", key: code
        end
        nil
      end
    end
  end
end
