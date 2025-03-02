require_relative "doctype"
require_relative "editorial_group"

module Relaton
  module Ogc
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[
        conceptual-model conceptual-model-and-encoding conceptual-model-and-implementation
        encoding extension implementation profile profile-with-extension general
      ]
      attribute :flavor, :string
      attribute :editorialgroup, EditorialGroup
      attribute :ics, Bib::ICS, collection: true

      xml do
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "flavor", to: :flavor
        map_element "editorialgroup", to: :editorialgroup
        map_element "ics", to: :ics
      end
    end
  end
end
