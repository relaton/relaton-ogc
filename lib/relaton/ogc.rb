require "relaton/index"
require "relaton/iso"
require_relative "ogc/version"
require_relative "ogc/util"
# require "relaton_ogc/document_type"
require_relative "ogc/item"
require_relative "ogc/bibitem"
require_relative "ogc/bibdata"
# require "relaton_ogc/ogc_bibliography"
# require "relaton_ogc/data_fetcher"
# require "relaton_ogc/hit_collection"
# require "relaton_ogc/scrapper"
# require "relaton_ogc/xml_parser"
# require "relaton_ogc/editorial_group"
# require "relaton_ogc/hash_converter"
# require "digest/md5"

module Relaton
  module Ogc
    class Error < StandardError; end

    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Ogc::VERSION + RelatonIso::Bib::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end
