require "relaton/index"
require "relaton_iso_bib"
require "relaton_ogc/version"
require "relaton_ogc/util"
require "relaton_ogc/document_type"
require "relaton_ogc/ogc_bibliographic_item"
require "relaton_ogc/ogc_bibliography"
require "relaton_ogc/data_fetcher"
require "relaton_ogc/hit_collection"
require "relaton_ogc/scrapper"
require "relaton_ogc/xml_parser"
require "relaton_ogc/editorial_group"
require "relaton_ogc/hash_converter"
require "digest/md5"

module RelatonOgc
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonOgc::VERSION + RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
  end
end
