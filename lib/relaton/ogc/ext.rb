require_relative "doctype"

module Relaton
  module Ogc
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[
        conceptual-model conceptual-model-and-encoding conceptual-model-and-implementation
        encoding extension implementation profile profile-with-extension general
      ]

      def get_schema_version = Relaton.schema_versions["relaton-model-ogc"]
    end
  end
end
